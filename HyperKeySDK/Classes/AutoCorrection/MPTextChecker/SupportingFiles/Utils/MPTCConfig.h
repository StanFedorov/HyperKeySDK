//
//  MPTCConfig.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 06.04.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern BOOL const kMPTCImportToDesktop;
extern NSString *const kMPTCSeparatorString;
extern NSUInteger const kMPTCLogStepSize;
extern NSUInteger const kMPTCLogStepSize;

extern NSUInteger const kMPTCNgramsLevels;
extern NSUInteger const kMPTCNgrams2MinWeight;
extern NSUInteger const kMPTCNgrams3MinWeight;
extern NSUInteger const kMPTCMaxWordWeight;
extern NSUInteger const kMPTCMinWordWeightFactor;
extern NSUInteger const kMPTCMaxNgramsFirstRepeats;

// Settings
extern NSString *const kMPTCSettings;

// Services
extern NSString *const kMPTCServiceScowlFrequency;
extern NSString *const kMPTCServiceScowl;
extern NSString *const kMPTCServiceYclist;

// Base
extern NSString *const kMPTCBaseScowlFrequency;
extern NSString *const kMPTCBaseScowl;
extern NSString *const kMPTCBaseYclist;

extern NSString *const kMPTCBaseUnigrams;
extern NSString *const kMPTCBaseNgrams;
extern NSString *const kMPTCBaseNgrams2;
extern NSString *const kMPTCBaseNgrams3;

extern NSString *const kMPTCBaseCustom;
extern NSString *const kMPTCBaseRemove;
extern NSString *const kMPTCBaseIgnore;
extern NSString *const kMPTCBaseReplace;

// Source
extern NSString *const kMPTCSourceDefaults;
extern NSString *const kMPTCSourceReplacements;
extern NSString *const kMPTCSourceTypos;
extern NSString *const kMPTCSourceUnigrams;
extern NSString *const kMPTCSourceNgrams2;
extern NSString *const kMPTCSourceNgrams3;

// Binary
extern NSString *const kMPTCDefaults;
extern NSString *const kMPTCReplacements;
extern NSString *const kMPTCTypos;
extern NSString *const kMPTCUnigrams;
extern NSString *const kMPTCNgrams;
