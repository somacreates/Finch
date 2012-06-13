#import "FIFactory.h"
#import "FISoundEngine.h"
#import "FIRevolverSound.h"
#import "FISample.h"
#import "FIDecoder.h"
#import "FISound.h"

@interface FIFactory ()
@property(strong) FIDecoder *decoder;
@end

@implementation FIFactory
@synthesize logger, soundBundle, decoder;

#pragma mark Public Components

- (FISoundEngine*) buildSoundEngine
{
    FISoundEngine *engine = [[FISoundEngine alloc] init];
    [engine setLogger:logger];
    return engine;
}

- (FISound*) loadSoundNamed: (NSString*) soundName error: (NSError**) error
{
    NSString *path = [soundBundle pathForResource:soundName ofType:nil];
    FISample *sample = [decoder decodeSampleAtPath:path error:error];
    return [[FISound alloc] initWithSample:sample error:error];
}

- (FISound*) loadSoundNamed: (NSString*) soundName maxPolyphony: (NSUInteger) voices error: (NSError**) error
{
    NSMutableArray *sounds = [NSMutableArray array];
    for (NSUInteger i=0; i<voices; i++) {
        FISound *voice = [self loadSoundNamed:soundName error:error];
        if (voice == nil)
            return nil;
        [sounds addObject:voice];
    }
    return (id) [[FIRevolverSound alloc] initWithVoices:sounds];
}

#pragma mark Initalization

- (id) init
{
    self = [super init];
    [self setLogger:FILoggerNull];
    [self setSoundBundle:[NSBundle mainBundle]];
    [self setDecoder:[[FIDecoder alloc] init]];
    return self;
}

@end
