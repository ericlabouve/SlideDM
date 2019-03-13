

import UIKit
import MapKit
import MessageKit
import MessageInputBar

// This class sets GUI properties for the chat room.
// This file's UI is a little awkward because avitars take up too much room and there is too much spacing between messages. It is better to use ChatRoomFancyViewController
final class ChatRoomSimpleViewController: ChatRoomBase {
  
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

// MARK: - MessagesDisplayDelegate

extension ChatRoomSimpleViewController: MessagesDisplayDelegate {
    
    
    
    // MARK: - Text Messages
    
    // Change the text color depending on the sender
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // Not sure what this one does
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    // Used to detect urls, addresses, phone numbers, dates,  ect.
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .leftMessageColor : .rightMessageColor
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tmessage = message as! TextMessage
        let color: UIColor = isFromCurrentSender(message: message) ? .leftMessageBorderColor : .rightMessageBorderColor
        if tmessage.showAvatar {
            let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            return .bubbleTailOutline(color, tail, .curved)
        } else {
            return .bubbleOutline(color)
        }
    }
    
    
    
    // An avatar is the circle image that appears next to your message
    // Replace this with a Snapkit image in the future
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        let tmessage = message as! TextMessage
        if tmessage.showAvatar {
            let initials = String(self.fromUser?.first.prefix(1) ?? "") + String(self.fromUser?.last.prefix(1) ?? "")
            let avatar = Avatar(image: nil, initials: initials)
            avatarView.set(avatar: avatar)
        } else {
            avatarView.isHidden = true
        }
    }
}

// MARK: - MessagesLayoutDelegate

// These properties can be set to dynamically size the message
extension ChatRoomSimpleViewController: MessagesLayoutDelegate {
    
    // Spacing for the center timestamp
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
         return 18
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
//        return 20
    }
    
    // Larger values push the avatar lower down
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let tmessage = message as! TextMessage
        if tmessage.showAvatar {
            return 16
        } else {
            return 0
        }
//        return 16
    }
    
}
