# WTTimer
Weak Target Timer for iOS

`WTTimer` will automatically invalidate itself when the target is deallocated and you should keep a strong reference 
to it, because if a instance of `WTTimer` is deallocated, the `NSTimer` it contains will be invalidated.

`WTTimer` has almost the same interface as `NSTimer`, it contains a `NSTimer` instance, when you create a `WTTimer` with
any one of its class method, it will create a instance of `TimerDelegateObject` and use it as the target of `NSTimer`, 
when timer fires, the delegate will delegate back to `WTTimer`.

## Installation

### From CocoaPods

pod 'weakTargetTimer', '~> 0.0.1'
