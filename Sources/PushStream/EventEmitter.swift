import Foundation



public class EventEmitter {
    private var eventListeners = [String: [(Any) -> Void]]()

  public  func on(_ event: String, listener: @escaping (Any) -> Void) {
        if eventListeners[event] == nil {
            eventListeners[event] = []
        }
        eventListeners[event]?.append(listener)
    }

    func emit(_ event: String, data: Any) {
        if let listeners = eventListeners[event] {
            for listener in listeners {
                listener(data)
            }
        }
    }

    func off(_ event: String, listener: @escaping (Any) -> Void) {
        if var listeners = eventListeners[event] {
            listeners.removeAll { $0 as AnyObject === listener as AnyObject }
            eventListeners[event] = listeners
        }
    }

    func removeAllListeners(_ event: String) {
        eventListeners[event] = nil
    }
}
