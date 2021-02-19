//
//  AsyncOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import Foundation

// my helper class to handle asynchronous
// operations within Operation subclasses

class AsyncOperation: Operation {
	
	enum State: String {
		case ready
		case executing
		case finished
		
		fileprivate var keyPath: String {
			"is\(rawValue.capitalized)"
		}
	}

	var state: State = .ready {
		willSet {
			willChangeValue(forKey: state.keyPath)
			willChangeValue(forKey: newValue.keyPath)
		}
		didSet {
			didChangeValue(forKey: oldValue.keyPath)
			didChangeValue(forKey: state.keyPath)
		}
	}

	// I see that she added this in a later vid - not in the original Create Async Operation vid
	override open var isReady: Bool {
		super.isReady && state == .ready
	}

	override var isExecuting: Bool {
		state == .executing
	}
	
	override var isFinished: Bool {
		state == .finished
	}
	
	override var isAsynchronous: Bool {
		true
	}

	override func start() {
		if isCancelled {
			state = .finished
			return
		}
		state = .executing
		main()
	}
	
	override func cancel() {
		state = .finished
	}
	
}
