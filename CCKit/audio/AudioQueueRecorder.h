//
//  AudioQueueRecorder.h
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*
 
 测试下来，在处于stopping状态的时候，就可以开启另一个对象来录音了，在stopping的时候，录音设备应该不工作了，是指把录音好的缓存发送给上层，所以此时可以开启其他对象来录音。但是对于播放设备，在stopping状态时，仍然需要播放完缓存中的对象，也就是说播放仍在继续。
 
                                                |--playing---|
 |--starting--|--playing--|--pause--|--playing--|--stopping--|--stopped--|
              |---------started-----------------|
 */
@protocol AudioQueueRecorderDelegate;
@interface AudioQueueRecorder : NSObject

- (instancetype)initWithDelegate:(id<AudioQueueRecorderDelegate>)delegate;

@property (nonatomic, weak, readonly) id<AudioQueueRecorderDelegate> delegate;
@property (nonatomic, readonly) AudioQueueRef audioQueue;

@property (nonatomic, getter=isRecording) BOOL recording;

- (BOOL)record;
- (void)stop;

- (BOOL)pause;

@property (nonatomic) id associatedData;

@end

@protocol AudioQueueRecorderDelegate <NSObject>

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfRecorder:(AudioQueueRecorder *)recorder;

- (void)audioQueueRecorder:(AudioQueueRecorder *)recorder recordBuffer:(AudioQueueBufferRef)buffer streamPacketDescList:(const AudioStreamPacketDescription *)inPacketDesc numberOfPacketDescription:(UInt32)inNumPackets;

- (void)audioQueueRecorderDidFinishRecord:(AudioQueueRecorder *)recorder;

@end
