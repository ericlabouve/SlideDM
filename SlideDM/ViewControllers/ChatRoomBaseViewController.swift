

import UIKit
import MessageKit
import MessageInputBar
import Firebase

// This class handles the functional responsibilities of the chat room such as database operations
class ChatRoomBaseViewController: MessagesViewController, MessagesDataSource {
    
    var fromUser: User!
    var toUser: User!
    var messageList: [TextMessage] = []
    
    var conversation: Conversation!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        // Configure the Message Input Bar
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.tintColor = .primaryColor
        
        title = toUser?.first
        
//        getConversation()
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        messagesCollectionView.addSubview(refreshControl)
    }

//    // Create a new conversation in Firebase if it does not already exist
//    func getConversation() {
//        // If this is not the first time fromUser is contacting toUser
//        if let conversationDocRef = fromUser?.getConversation(withId: (toUser?.phoneID)!) {
//            conversationDocRef.ref.getDocument{ (document, error) in
//                guard let conversationDoc = document, conversationDoc.exists else {
//                    print("Error: fromUser \(self.fromUser?.phoneID) has no conversation with \(self.toUser?.phoneID) even through from user has a reference to toUser.")
//                    return
//                }
//                self.conversation = Conversation(snapshot: conversationDoc)
//            }
//        } else {
//            // This is the first message of the conversation.
//
//            // 1. Make a new conversation locally and save in Firestore
//            self.conversation = Conversation(fromUserRef: (fromUser?.ref)!, toUserRef: (toUser?.ref)!)
//            let ref = FirestoreService.shared.conversationsRef.addDocument(data: conversation.toDict())
//
//            // 2. Update toUser and fromUser locally and save in Firestore
//            fromUser.conversations.append(User.ConversationDocRef(ref: ref, toUser: toUser.phoneID))
//            toUser.conversations.append(User.ConversationDocRef(ref: ref, toUser: fromUser.phoneID))
//            fromUser.ref?.setData(fromUser.toDict())
//            toUser.ref?.setData(toUser.toDict())
//        }
//    }
    
    
    func insertMessage(_ message: TextMessage) {
        
        // When a message is sent, we initialize a conversation in Firestore if one does not already exist
        messageList.append(message)
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
extension ChatRoomBaseViewController: MessageCellDelegate {
//    func didTapAvatar(in cell: MessageCollectionViewCell) {
//        print("Avatar tapped")
//    }
}


// MARK: - MessageInputBarDelegate

extension ChatRoomBaseViewController: MessageInputBarDelegate {
    
    // Handles everything that happens when a message is sent
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            // We can extend this to more than just text messages. Check out the original source code for more details
            if let str = component as? String {
                let message = TextMessage(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
        // Clear the input bar
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
}
