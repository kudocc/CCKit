//
//  AudioQueuePlayer.h
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*
                                                |--playing--|
 |--starting--|--playing--|--pause--|--playing--|--stoping--|--stoped--|
              |---------started-----------------|
 */

@protocol AudioQueuePlayerDelegate;
@interface AudioQueuePlayer : NSObject

- (instancetype)initWithDelegate:(id<AudioQueuePlayerDelegate>)delegate;

@property (nonatomic, weak, readonly) id<AudioQueuePlayerDelegate> delegate;
@property (nonatomic, readonly) AudioQueueRef audioQueue;

@property (nonatomic, getter=isPlaying) BOOL playing;

- (BOOL)play;
- (void)stop;

- (BOOL)pause;

@end

@protocol AudioQueuePlayerDelegate <NSObject>

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfPlayer:(AudioQueuePlayer *)player;

- (void)audioQueuePlayer:(AudioQueuePlayer *)player
       getBufferByteSize:(UInt32 *)outBufferSize
      packetToReadNumber:(UInt32 *)outPacketToReadNumber;

- (void)audioQueuePlayer:(AudioQueuePlayer *)player
             primeBuffer:(AudioQueueBufferRef)inAudioQueueBuffer
 streamPacketDescription:(AudioStreamPacketDescription *)inPacketDesc
       descriptionNumber:(UInt32)inNumPackets
        readPacketNumber:(UInt32 *)outReadPacketNumber
          readByteNumber:(UInt32 *)outReadByteNumber;

- (void)audioQueuePlayerDidFinishPlay:(AudioQueuePlayer *)player;

@end
