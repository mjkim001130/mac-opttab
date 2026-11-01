// Option+Tab -> system Cmd+Tab. Rewrites keyboard events only; never queries windows of other apps.
import Cocoa

let tabKey: Int64 = 48
let commandKey: CGKeyCode = 55
let syntheticMark: Int64 = 0x4F505454
var cmdHeld = false

func postCommand(down: Bool) {
    guard let event = CGEvent(keyboardEventSource: nil, virtualKey: commandKey, keyDown: down) else { return }
    event.flags = down ? .maskCommand : []
    event.setIntegerValueField(.eventSourceUserData, value: syntheticMark)
    event.post(tap: .cghidEventTap)
}

var tap: CFMachPort?

let callback: CGEventTapCallBack = { _, type, event, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
        return Unmanaged.passUnretained(event)
    }
    if event.getIntegerValueField(.eventSourceUserData) == syntheticMark {
        return Unmanaged.passUnretained(event)
    }
    let flags = event.flags
    if type == .flagsChanged {
        if cmdHeld && !flags.contains(.maskAlternate) {
            cmdHeld = false
            postCommand(down: false)
        }
        return Unmanaged.passUnretained(event)
    }
    let isTab = event.getIntegerValueField(.keyboardEventKeycode) == tabKey
    if cmdHeld || (isTab && type == .keyDown && flags.contains(.maskAlternate)) {
        if !cmdHeld {
            cmdHeld = true
            postCommand(down: true)
        }
        // While held, arrows/Esc/Q also reach the system switcher as Cmd combos.
        event.flags = flags.subtracting(.maskAlternate).union(.maskCommand)
    }
    return Unmanaged.passUnretained(event)
}

let prompt = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
AXIsProcessTrustedWithOptions(prompt)
while !AXIsProcessTrusted() { sleep(1) }

let mask = CGEventMask((1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue))
tap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap,
                        eventsOfInterest: mask, callback: callback, userInfo: nil)
guard let tap else { exit(1) }
CFRunLoopAddSource(CFRunLoopGetMain(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)
CFRunLoopRun()
