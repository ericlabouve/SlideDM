//
// TODO
// [x] BUG: Using the refreshController once all messages are loaded

import UIKit
import MessageKit
import MessageInputBar
import Firebase
import CodableFirebase

// This class handles the functional responsibilities of the chat room such as database operations
class ChatRoomBase: MessagesViewController, MessagesDataSource, ConversationListener {
    
    var fromUser: SDMUser!
    var toUser: SDMUser!
    var messageList: [TextMessage] = []
    
    var conversation: Conversation!
    // This query will retrieve messages from the database
    var getMoreMessagesQuery: Query?
    // Number of messages to initially and subsequently load with the refresh controller
    var count: Int = 10
    // Scroll wheel at the top to get older, paginated messages
    let refreshControl = UIRefreshControl()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
        
        title = toUser?.first

        getConversation()
        loadFirstMessages()
        
        // Start listening for new messages
        conversation.addConversationListener(listener: self)
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        messagesCollectionView.addSubview(refreshControl)
        // Pull down to receive more messages
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    func configureMessageInputBar() {
        // Configure the Message Input Bar
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .leftMessageColor
        messageInputBar.sendButton.tintColor = .leftMessageColor
    }

    
    
    // MARK: - Get Conversation

    // Get the current conversation between the two users or
    // create a new conversation in Firebase if it does not already exist
    func getConversation() {
        // There already exists a conversation
        if let conversation_ = fromUser.getConversationWith(userID: toUser.phoneID) {
            self.conversation = conversation_
        // There does not already exist a conversation
        } else {
            createConversation()
        }
    }
    
    func createConversation() {
        // 1. Make a new conversation locally and save in Firestore
        conversation = Conversation(fromUser: fromUser, toUser: toUser)
        var conversationData = try! FirestoreEncoder().encode(conversation)
        let ref = FirestoreService.shared.conversationsColRef.addDocument(data: conversationData)
        conversation.ref = ref
        conversationData = try! FirestoreEncoder().encode(conversation)
        
        // 2. Update toUser and fromUser with the current conversation and update them locally and save in Firestore
        fromUser.ref?.collection("conversations").addDocument(data: conversationData)
        toUser.ref?.collection("conversations").addDocument(data: conversationData)
    }
    
    
    
    // MARK: - Load Messages
    
    func loadFirstMessages() {
        self.getMessages { messages in
            DispatchQueue.main.async {
                self.messageList = messages
                self.cleanSpeechBubbles()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
    }
    
    // Connected to the spinning refresh control
    @objc func loadMoreMessages() {
        self.getMessages { messages in
            DispatchQueue.main.async {
                self.messageList.insert(contentsOf: messages, at: 0)
                self.cleanSpeechBubbles()
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
            }
        }
    }

    // Uses pagination to load messages
    func getMessages(completion: @escaping ([TextMessage]) -> Void) {
        guard let messagesColRef = conversation.ref?.collection("messages") else { return }
        if self.getMoreMessagesQuery == nil {
            self.getMoreMessagesQuery = messagesColRef
                                        .order(by: "timestampDate", descending: true)
                                        .limit(to: count)
        }
        self.getMoreMessagesQuery?.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { print("Error retreving messages: \(error.debugDescription)"); return }
            // Store the lastSnapshot in order to create the next query if the user wants to see more messages
            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                DispatchQueue.main.async { self.refreshControl.endRefreshing() }
                return
            }
            var messages = [TextMessage]()
            for qDocSnapshot in snapshot.documents {
                messages.insert(TextMessage(snapshot: qDocSnapshot), at: 0)
            }
            
            // Construct a new query starting after this document just in case the user scrolls up to see more messages
            self.getMoreMessagesQuery = messagesColRef
                                        .order(by: "timestampDate", descending: true)
                                        .limit(to: self.count)
                                        .start(afterDocument: lastSnapshot)
            // Display the messages in the view
            completion(messages)
        }
    }
    
    
    // MARK: - ConversationListener
    
    // Add a new message to the conversation
    func conversationChanged(conversation: Conversation, textMessage: TextMessage) {
        let fromId = textMessage.id
        if fromId == toUser.phoneID {
            insertMessage(textMessage)
        }
    }
    
    
    // MARK: - Insert Message at Bottom with Animation
    
    func insertMessage(_ message: TextMessage) {
        // When a message is sent, we initialize a conversation in Firestore if one does not already exist
        messageList.append(message)
        cleanSpeechBubbles()
        updateCollectionView()
    }

    // Not sure what this does exactly. I extracted the closure call to clean up insertMessage()
    func updateCollectionView() {
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    
    // Group speech bubbles together so that the avatar only appears on the last message
    func cleanSpeechBubbles() {
        var prevMessage: TextMessage!
        for (idx, message) in messageList.enumerated() {
            if idx > 0 && prevMessage.id != message.id {
                messageList[idx - 1].showAvatar = true
            }
            messageList[idx].showAvatar = false
            prevMessage = message
        }
        // Last message always has avatar turned on
        messageList[messageList.count - 1].showAvatar = true
    }
    
    
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> Sender {
        // Will need to restart the app from the LogingViewController to get credentials. But also a good idea to remove users tree in Firestore
        return Sender(id: (fromUser?.phoneID)!, displayName: (fromUser?.first)!)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // Sets the date of the last message in the center of the screen
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    // SEE ORIGINAL DOCUMENTATION TO CHANGE TOP AND BOTTOM LABELS
    
}





// MARK: - MessageCellDelegate

// Can extend MessageCellDelegate to handle tap events. One avenue for future work would be to look at someone's profile when their icon is tapped.
extension ChatRoomBase: MessageCellDelegate {
//    func didTapAvatar(in cell: MessageCollectionViewCell) {
//        print("Avatar tapped")
//    }
}






// MARK: - MessageInputBarDelegate

extension ChatRoomBase: MessageInputBarDelegate {
    
    // Handles everything that happens when a message is sent
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            // We can extend this to more than just text messages. Check out the original source code for more details
            if let str = component as? String {
                let message = TextMessage(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertMessage(message)
                // Save message to database
                conversation.ref?.collection("messages").addDocument(data: message.toDict())
            }
        }
        // Clear the input bar
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

extension UIColor {
    static let leftMessageColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    static let leftMessageBorderColor = UIColor(red: 84/255, green: 208/255, blue: 104/255, alpha: 1)
    
    static let rightMessageColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    static let rightMessageBorderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    static let avatarBorderColor = UIColor(red: 86/255, green: 149/255, blue: 246/255, alpha: 1)
}
