//
//  UIScreen+Orientation.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import "NSObject+Additions.h"

#include <mach/mach_time.h>

@implementation NSObject (Additions)

// Returns block execution time in nanoseconds
+ (double)blockExecutionTime:(void(^)())block {
	const uint64_t startTime = mach_absolute_time();
	
	block();
	
	const uint64_t endTime = mach_absolute_time();
    const uint64_t elapsedMTU = endTime - startTime;
	
	mach_timebase_info_data_t info;
	if (mach_timebase_info(&info)) {
		// Handle error condition
	}
	return (double)elapsedMTU * (double)info.numer / (double)info.denom;
}

// Output block execution time
+ (void)logBlockExecutionTimeWithName:(NSString *)name block:(void(^)())block {
	double elapsedNS = [self blockExecutionTime:block];
	
	// Output elapsed time in microseconds
	if (elapsedNS > 1000000000.0) {
		NSLog(@"%@ [%.2f s]", name, elapsedNS / 1000000000.0);
	} else if (elapsedNS > 1000000.0) {
		NSLog(@"%@ [%.2f ms]", name, elapsedNS / 1000000.0f);
	} else if (elapsedNS > 1000) {
		NSLog(@"%@ [%.2f μs]", name, elapsedNS / 1000.0f);
	} else {
		NSLog(@"%@ [%.2f ns]", name, elapsedNS);
	}
}

@end
