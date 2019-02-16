//
//  MPTCConfig.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 06.04.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCConfig.h"

// Constants
BOOL const kMPTCImportToDesktop             = YES;
NSString *const kMPTCSeparatorString        = @"|";
NSUInteger const kMPTCLogStepSize           = 50000;

NSUInteger const kMPTCNgramsLevels          = 3;
NSUInteger const kMPTCNgrams2MinWeight      = 16;
NSUInteger const kMPTCNgrams3MinWeight      = 32;
NSUInteger const kMPTCMaxWordWeight         = 50000;
NSUInteger const kMPTCMinWordWeightFactor   = 3;
NSUInteger const kMPTCMaxNgramsFirstRepeats = 999;

// Settings
NSString *const kMPTCSettings               = @"mptc_settings";

// Services
NSString *const kMPTCServiceScowlFrequency  = @"mptc_service_scowl_frequency";
NSString *const kMPTCServiceScowl           = @"mptc_service_scowl";
NSString *const kMPTCServiceYclist          = @"mptc_service_yclist";

// Base
NSString *const kMPTCBaseScowlFrequency     = @"mptc_base_scowl_frequency";
NSString *const kMPTCBaseScowl              = @"mptc_base_scowl";
NSString *const kMPTCBaseYclist             = @"mptc_base_yclist";

NSString *const kMPTCBaseUnigrams           = @"mptc_base_unigrams";
NSString *const kMPTCBaseNgrams             = @"mptc_base_ngrams";
NSString *const kMPTCBaseNgrams2            = @"mptc_base_ngrams_2";
NSString *const kMPTCBaseNgrams3            = @"mptc_base_ngrams_3";

NSString *const kMPTCBaseCustom             = @"mptc_base_custom";
NSString *const kMPTCBaseRemove             = @"mptc_base_remove";
NSString *const kMPTCBaseIgnore             = @"mptc_base_ignore";
NSString *const kMPTCBaseReplace            = @"mptc_base_replace";

// Source
NSString *const kMPTCSourceDefaults         = @"mptc_source_defaults";
NSString *const kMPTCSourceReplacements     = @"mptc_source_replacements";
NSString *const kMPTCSourceTypos            = @"mptc_source_typos";
NSString *const kMPTCSourceUnigrams         = @"mptc_source_unigrams";
NSString *const kMPTCSourceNgrams2          = @"mptc_source_ngrams_2";
NSString *const kMPTCSourceNgrams3          = @"mptc_source_ngrams_3";

// Binary
NSString *const kMPTCDefaults               = @"mptc_defaults";
NSString *const kMPTCReplacements           = @"mptc_replacements";
NSString *const kMPTCTypos                  = @"mptc_typos";
NSString *const kMPTCUnigrams               = @"mptc_unigrams";
NSString *const kMPTCNgrams                 = @"mptc_ngrams";
