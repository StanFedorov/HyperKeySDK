//
//  CamFindViewController.m
//  BetterWord
//
//  Created by Stanislav Fedorov on 23.02.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "AmazonViewController.h"
#import "AmazonTableViewCell.h"
#import "ImagesLoadingAndSavingManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+URLEncode.h"
#import "XMLReader.h"
#import "KeyboardConfig.h"
#import "HProgressHUD.h"
#import "AmazonPageViewController.h"
#import "GifCategoryCell.h"

@interface AmazonViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak,nonatomic) IBOutlet UITableView *resultsTable;
@property (strong,nonatomic) NSMutableArray *searchResults;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *hudContainerView;
@property (nonatomic) BOOL searchInProgress;
@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
@property (strong, nonatomic) NSArray *categoriesArray;
@property (strong, nonatomic) NSArray *categoriesArrayIds;
@property (strong, nonatomic) UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UILabel *empty;
@property (nonatomic) int itemPage;
@property (nonatomic) NSString *activeCategory;
@property (nonatomic) NSString *activeCategoryName;
@end

@implementation AmazonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.hoverView.seletedSocialType = HoverViewSocialTypeDropBox;
    self.searchField.delegate = self;
    self.resultsTable.tableFooterView = [UIView new];
    self.searchResults = [NSMutableArray new];
    [SDWebImageManager sharedManager].delegate = self;
    //  [self searchAmazon:@"Amazon"];
    
    [self showEmpty];
    
    NSString* cellName = NSStringFromClass([GifCategoryCell class]);
    [self.categoriesCollectionView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle bundleForClass:GifCategoryCell.class]] forCellWithReuseIdentifier:cellName];

    self.categoriesArray = @[@"All", @"Appliances", @"Arts, Crafts & Sewing", @"Automotive", @"Baby", @"Beauty",@"Books",@"Collectibles & Fine Arts",@"Electronics",@"Clothing, Shoes & Jewelry",@"Gift Cards",@"Grocery & Gourmet Food",@"Handmade",@"Health & Personal Care",@"Home & Kitchen",@"Industrial & Scientific",@"Kindle Store",@"Patio, Lawn & Garden",@"Luggage & Travel Gear",@"Magazine Subscriptions",@"CDs & Vinyl",@"Musical Instruments",@"Office Products",@"Prime Pantry",@"Computers",@"Pet Supplies",@"Software",@"Sports & Outdoors",@"Tools & Home Improvement",@"Toys & Games",@"Vehicles",@"Cell Phones & Accessories"];
    self.categoriesArrayIds = @[@"All", @"Appliances", @"ArtsAndCrafts", @"Automotive", @"Baby", @"Beauty",@"Books",@"Collectibles",@"Electronics",@"Fashion",@"GiftCards",@"Grocery",@"Handmade",@"HealthPersonalCare",@"HomeGarden",@"Industrial",@"KindleStore",@"LawnAndGarden",@"Luggage",@"Magazines",@"Music",@"MusicalInstruments",@"OfficeProducts",@"Pantry",@"PCHardware",@"PetSupplies",@"Software",@"SportingGoods",@"Tools",@"Toys",@"Vehicles",@"Wireless"];
    
 
    [self.categoriesCollectionView reloadData];
    
    self.activeCategory = @"All";
    [self.categoriesCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)showEmpty {
    if(self.moreButton != nil) {
        [self.moreButton removeFromSuperview];
        self.moreButton = nil;
    }
    [self.searchResults removeAllObjects];
    [self addFakeItemWithTitle:@"Multi-pot 10-in-1 Programmable Instant Pressure Cooker 6 Quarts with Stainless Steel Pot, Free Recipe Book Included. 1000 Watt Pressure, Slow Cook, Sauté, Rice Cooker, Steamer & Warmer by SilverOnyx" price:@"$98.02" seller:@"by SilverOnyx" image:@"https://images-na.ssl-images-amazon.com/images/I/71wzRG9g6CL._SL1500_.jpg" link:@"https://www.amazon.com/Multi-pot-Programmable-Stainless-Included-SilverOnyx/dp/B07CPM4DGD/ref=as_li_ss_tl?s=kitchen&ie=UTF8&qid=1542940946&sr=1-1-spons&keywords=instant+pot&psc=1&linkCode=sl1&tag=hyperk-20&linkId=0b18932f3078b86d96ce444b7dbf52e3" features:@[@"✔️ 100% MONEY BACK GUARANTEE - We remove all risk. You have no need to worry about not loving your purchase as we promise to return 100% of your money if you are not completely satisfied with your purchase.",@"✔️ PREMIUM STAINLESS STEEL POT: The SilverOnyx Electric Pressure Cooker features a durable stainless steel pot, instant cooker that won't peel or chip like other non-stick pots. Stainless steel is easy to clean and looks like new for years.",@"✔️ 10-IN-1 MULTIFUNCTION COOKER: Pressure cooker, chicken, meat/stew, steamer, sauté, slow cooker, rice cooker, grains, yogurt maker, food warmer. Includes 14 built-in smart programs for fast and easy cooking.",@"✔️ FREE PRESSURE COOKER COOKBOOK: Get started cooking sooner with the top 20 pressure cooker recipes for main dishes, sides, and desserts. Each pressure cooker recipe includes simple step-by-step instructions.",@"✔️ RELATED: electric pressure cooker 6 quart 10 4 600 8 aroma automatic beef best canner canning chicken cookbook cookers cooking cooks corned countertop cpc crock cuisinart digital duo easy elite essentials fagor fal farberware fissler food handle home inserts instant large meals microwave mirro multi new pot power press prestige presto puck qt qvc rated recipes reviews rice roast sale set silveronyx slow small stainless steel stew stove stovetop t top vs wolfgang work xl."]];
    [self addFakeItemWithTitle:@"Keurig K55/K-Classic Coffee Maker, K-Cup Pod, Single Serve, Programmable, Black" price:@"$79.99" seller:@"By Keurig" image:@"https://images-na.ssl-images-amazon.com/images/I/71Ikuq6AAfL._SL1500_.jpg" link:@"https://www.amazon.com/www.amazon.com/dp/B018UQ5AMS/ref=as_li_ss_tl?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=merchandised-search-6&pf_rd_r=GAD1RMBSG9C1F7ZQDF4F&pf_rd_t=101&pf_rd_p=69ccdeb9-a8ec-4302-8d6a-05f5b2696160&pf_rd_i=18108203011&linkCode=sl1&tag=hyperk-20&linkId=0ffafcb180522d20c841b60a0582963b" features:@[@"The Classic Keurig K-Cup Single Serve Coffee Maker includes 4 K-Cup pods, a water filter handle and 2 water filters to help your beverages taste their best.",@"BREWS MULTIPLE K-CUP POD SIZES: (6, 8, 10 oz.) – the most popular K-Cup pod brew sizes. Use the 6oz brew size to achieve the strongest brew.",@"LARGE 48 oz. WATER RESERVOIR: Allows you to brew 6+ cups before having to refill, saving you time and simplifying your morning routine. The water reservoir is removable, making it easy to refill whenever you need to.",@"DESCALING: An important part of cleaning your Keurig brewer. This process helps to remove calcium deposits, or scale, that can build up inside a coffee maker over time. Please refer to our descaling video for step by step instructions.",@"AUTO-OFF: An auto-off feature is easily programmed to turn off your coffee maker after it has been idle for two hours, helping to save energy.",@"The Classic Series K55 were introduced as the brewer gift boxes. These names refer to the entire retail package (the new gift box, the brewer, and any other items packed within the box). However, the model number on the brewer is the K40, as no changes were made to the brewer."]];
    [self addFakeItemWithTitle:@"ASUS VivoBook S Thin & Light Laptop, 14\" FHD, Intel Core i7-8550U, 8GB RAM, 256GB SSD, GeForce MX150, NanoEdge Display, Backlit Kbd, FP Sensor - S410UN-NS74" price:@"$799.00" seller:@"by Asus" image:@"https://images-na.ssl-images-amazon.com/images/I/81CXyTkBjWL._SL1500_.jpg" link:@"https://www.amazon.com/VivoBook-i7-8550U-GeForce-NanoEdge-Display/dp/B07B7VFTN9/ref=as_li_ss_tl?ref_=Oct_DLandingS_PC_a926dcb7_NA&smid=ATVPDKIKX0DER&linkCode=sl1&tag=hyperk-20&linkId=a91d57f70d4016822fab7b5c902fc337" features:@[@"8th Generation Intel Core i7-8550U (Turbo up to 4.0GHz) quad-core processor and dedicated NVIDIA GeForce MX150 graphics 2GB",@"8GB DDR4 RAM and 256GB SSD",@"14\" Full HD WideView display with up to 178° WideView and ASUS NanoEdge bezel for a stunning 77% screen-to-body ratio",@"Slim 12.8\" wide, 0.7\" thin and portable footprint with metal cover and backlit keyboard with fingerprint sensor",@"Comprehensive connections including USB 3.1 Type-C (Gen1), USB 3.0, USB 2.0, HDMI, & headphone/mic combo port"]];
    [self addFakeItemWithTitle:@"Acer Aspire C24-865-ACi5NT AIO Desktop, 23.8\" Full HD, 8th Gen Intel Core i5-8250U, 12GB DDR4, 1TB HDD, 802.11ac WiFi, Wireless Keyboard and Mouse, Windows 10 Home" price:@"$677.99 " seller:@"by Acer" image:@"https://images-na.ssl-images-amazon.com/images/I/71YktzGiStL._SL1500_.jpg" link:@"https://www.amazon.com/Acer-C24-865-ACi5NT-i5-8250U-802-11ac-Wireless/dp/B07CY79CKZ/ref=as_li_ss_tl?ref_=Oct_DLandingS_PC_a926dcb7_NA&smid=ATVPDKIKX0DER&linkCode=sl1&tag=hyperk-20&linkId=fc29eaf82f1059b3347ef1601fa59b90" features:@[@"8th Generation Intel Core i5-8250U Processor 1.6GHz (Up to 3.4GHz)",@"23.8\" Full HD (1920 x 1080) Widescreen Edge-to-Edge LED Back-lit Display",@"12GB DDR4 2400MHz Memory & 1TB 5400RPM SATA Hard Drive",@"802.11ac Wi-Fi, Gigabit Ethernet LAN & Bluetooth 4.2LE",@"Built-in Stereo Speakers | External 1 MP Webcam (via USB Connector) | Wireless Keyboard and Mouse"]];
    [self addFakeItemWithTitle:@"Breville BOV900BSS Smart Oven with Air Fry, Brushed Stainless Steel" price:@"$399.95" seller:@"by Breville" image:@"https://images-na.ssl-images-amazon.com/images/I/81%2BQw7sZ6AL._SL1500_.jpg" link:@"https://www.amazon.com/dp/B01N5UPTZS/ref=as_li_ss_tl?smid=ATVPDKIKX0DER&pf_rd_p=bff00e03-28cd-49c9-a3ae-00425a013401&pf_rd_s=merchandised-search-5&pf_rd_t=101&pf_rd_i=18108205011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=S13JRDZTXJAN012HDF58&linkCode=sl1&tag=hyperk-20&linkId=e54923ccb46f583d841160f95b9e0483" features:@[@"SUPER CONVECTION TECHNOLOGY: 2-speed convection fan (Super & regular) offers greater cooking control. Super convection provides a greater volume of air to ensure fast and even heat distribution, perfect for air frying, dehydration and roasting.",@"PRECISION COOKING & ELEMENT IQ: With Element IQ - 6 Independent quartz heating elements move the power where it's needed most, above and below the food for perfect results.",@"AIR FRY & DEHYDRATE PRESETS: Why buy a stand alone air fryer or dehydrater when the Smart Oven Air can air fry french fries and other family favorites and dehydrate a range of foods. Dehydrate up to 4 trays of goodness.",@"SIZE MATTERS: The large, 1 cubic ft, interior makes room for toasting 9 slices of bread, roasting a 14-lb turkey, air fry favorites like French fries, slow cook with a 5 qt Dutch oven and comfortably fit most 9\"x13\" pans and 12 cup muffin trays.",@"SUPER VERSATILE: 13 cooking functions to guide you to perfection: Toast 9 slices, Bagel, Broil, Bake, Roast, Warm, Pizza, Proof, Airfry, Reheat, Cookies, Slow Cook, Dehydrate.",@"LCD DISPLAY: To easily access the built in smart functionality, choose from 13 cooking functions. Integrated oven light automatically turns on at the end of cooking cycle or can be switched at the touch of a button.",@"WARRANTY: 2 Year Limited Product Warranty"]];
    [self addFakeItemWithTitle:@"Philips Smoke-less Indoor BBQ Grill, Avance Collection, HD6371/94" price:@"$249.95" seller:@"by Philips" image:@"https://images-na.ssl-images-amazon.com/images/I/61b29upPGfL._SL1350_.jpg" link:@"https://www.amazon.com/gp/product/B07D12RYS8/ref=as_li_ss_tl?ref=oft18_d_B07D12RYS8_AL_15_p&linkCode=sl1&tag=hyperk-20&linkId=1b1fd406d575e80ee7e0bb8a93f16f90" features:@[@"Advanced infrared technology and special reflectors guide heat to the indoor grills cooking grid for delicious, evenly grilled food. The drip tray underneath remains cool so there is virtually no smoke.",@"No need to adjust the heat! The indoor grill quickly heats up to a consistent 446°F, the optimal temperature for cooking and searing your favorite meat, poultry and fish leaving it juicy and tender on the inside.",@"The electric grill ensures food is not cooked into its own grease and the fat is separated during grilling ; Voltage: 120 V",@"Clean up your electric grill in less than a minute! Either wipe the grid clean or place it in the dishwasher. Cleaning a grill has never been easier.",@"The indoor grill sets up in 1-minute - spend more time cooking and less on prep. Powerful 1660 Watts for cooking and non-slip feet to ensure your electric grill stays in place."]];
    [self addFakeItemWithTitle:@"Breathe Whipped Body Butter & Dry Body Oil Set" price:@"$65.00" seller:@"by Lollia" image:@"https://images-na.ssl-images-amazon.com/images/I/81xN7SAGR8L._SL1500_.jpg" link:@"https://www.amazon.com/gp/product/B07HP8661L/ref=as_li_ss_tl?ref=oft18_d_B07K1V1R55_AL_35_p&th=1&linkCode=sl1&tag=hyperk-20&linkId=6180b2c47fbdd3e1a1a39e96dfa3ab8e" features:@[@"Sheer Hydration. Lush and gentle for a moisture-rich pick-me-up",@"Delightfully fragranced with ruffled Peony & White Lily and sheer hints of fresh Grapefruit & Orange infused with leafy green notes",@"A classic humectant formulated with lush botanicals to nourish & lock in moisture",@"Hydrating Coconut & Sweet Almond Oils pair with soothing Pomegranate & Green Tea for a light moisturizer perfect for all skin types and beneficial for dry and sensitive skin",@"Lollia by Margot Elena is based in Denver, Colorado"]];
    [self addFakeItemWithTitle:@"SanDisk 400GB Ultra microSDXC UHS-I Memory Card with Adapter - 100MB/s, C10, U1, Full HD, A1, Micro SD Card - SDSQUAR-400G-GN6MA" price:@"$99.99" seller:@"by SanDisk" image:@"https://images-na.ssl-images-amazon.com/images/I/510Kzz4c1bL._SL1100_.jpg" link:@"https://www.amazon.com/SanDisk-Ultra-400GB-Adapter-SDSQUAR-400G-GN6MA/dp/B074RNRM2B/ref=as_li_ss_tl?ref_=Oct_DLandingS_PC_d708a601_NA&smid=ATVPDKIKX0DER&linkCode=sl1&tag=hyperk-20&linkId=8ea3de02e8e65068cc5d8c48672a5613" features:@[@"Up to 400GB (1GB=1,000,000,000 bytes. Actual user storage less. ) to store even more hours of Full HD video (Approximations; results and Full HD (1920x1080) video support may vary based on host device, file attributes and other factors. )",@"Class 10 for Full HD video recording and playback (Full HD (1920x1080) video support may vary based upon host device, file attributes, and other factors. )",@"Up to 100MB/s transfer read speed (Based on internal testing; performance may be lower depending on host device, interface, usage conditions and other factors. ) lets you move up to 1200 photos in a minute (Based on 4. 1GB transfer of photos (avg. file 3. 5MB) with USB 3. 0 reader. Results may vary based on host device, file attributes and other factors. )",@"Load apps faster with A1-rated performance (Results may vary based on host device, app type and other factors. )",@"deal for Android smartphones and tablets, and MIL cameras"]];
    [self addFakeItemWithTitle:@"PlayStation 4 Slim 1TB Console" price:@"$299.99" seller:@"by Sony" image:@"https://images-na.ssl-images-amazon.com/images/I/71PGvPXpk5L._AC_.jpg" link:@"https://www.amazon.com/PlayStation-4-Slim-1TB-Console/dp/B071CV8CG2/ref=sr_1_1?s=electronics&ie=UTF8&qid=1543528078&sr=1-1&keywords=PS4&tag=hyperk-20" features:@[@"All new lighter slimmer PS4",@"1TB hard drive",@"All the greatest, games, TV, music and more"]];
    [self addFakeItemWithTitle:@"Bose QuietComfort 35 (Series II) Wireless Headphones, Noise Cancelling, with Alexa voice control - Black" price:@"$299.00" seller:@"by Bose" image:@"https://images-na.ssl-images-amazon.com/images/I/61JPyEqYGQL._SL1000_.jpg" link:@"https://www.amazon.com/Bose-QuietComfort-Wireless-Headphones-Cancelling/dp/B0756CYWWD/ref=as_li_ss_tl?smid=ATVPDKIKX0DER&pf_rd_p=28886d39-4b43-40e8-86b1-445d3a05dcc5&pf_rd_s=merchandised-search-1&pf_rd_t=101&pf_rd_i=15450561011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=ESKQQGPHB0T1Q908Z2Y5&linkCode=sl1&tag=hyperk-20&linkId=c369ba04caa249d1290913a2186b9dd8" features:@[@"Three levels of world-class noise cancellation for better listening experience in any environment",@"Alexa-enabled for voice access to music, information, and more",@"Noise-rejecting dual-microphone system for clear sound and voice pick-up",@"Balanced audio performance at any volume",@"Hassle-free Bluetooth pairing, personalized settings, access to future updates, and more through the Bose Connect app",]];
    [self addFakeItemWithTitle:@"WD 4TB Gaming Drive" price:@"$109.99" seller:@"by Western Digital" image:@"https://images-na.ssl-images-amazon.com/images/I/61mtL65D4cL._SL1500_.jpg" link:@"https://www.amazon.com/Gaming-Drive-Playstation-Portable-External/dp/B07HKN92MZ/ref=as_li_ss_tl?ref_=Oct_DLandingS_PC_d708a601_NA&smid=ATVPDKIKX0DER&linkCode=sl1&tag=hyperk-20&linkId=44d07e10fafed29d46bd50b796c242c1" features:@[@"Expand your PS4 gaming experience",@"Play anywhere",@"Fast and easy setup",@"Sleek design with high capacity",@"3-year manufacturer's limited warranty"]];
    [self addFakeItemWithTitle:@"Philips Sonicare DiamondClean" price:@"$226.55" seller:@"by Philips Sonicare" image:@"https://images-na.ssl-images-amazon.com/images/I/61FiJEpfvlL._SL1300_.jpg" link:@"https://www.amazon.com/dp/B06XSH2QTJ/ref=as_li_ss_tl?%20smid=A1QTP2UD1VCGU5&pf_rd_p=013ecda5-8fb9-4b75-94ae-04e7ba39390b&pf_rd_s=merchan%20dised-%20search-10&pf_rd_t=101&pf_rd_i=16713792011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=6PWJXADT%20H9RR109XG57F&th=1&linkCode=sl1&tag=hyperk-20&linkId=2cbdaeccfdec2d711ec75d6979bb10%20b7" features:@[@"Philips Sonicare's best ever toothbrush for the most exceptional clean and complete care",@"Removes up to 10x more plaque and improves gum health up to 7x in just 2 weeks (in gum health mode vs. a manual toothbrush)",@"Removes up to 100% more stains in just 3 days (in white+ mode vs. a manual toothbrush)",@"4 different smart brush head types automatically pair with the appropriate brushing mode and smart sensors provide real time feedback",@"5 modes: Clean, White+, Deep Clean+, Gum Health, TongueCare & 3 intensity levels"]];
    [self addFakeItemWithTitle:@"Vitamix Professional Series 300 Blender" price:@"$512.18" seller:@"by Vitamix" image:@"https://images-na.ssl-images-amazon.com/images/I/717sRToNRjL._SL1500_.jpg" link:@"https://www.amazon.com/Vitamix-Professional-300-Container-Onyx/dp/B00ELNA6TW/ref=as_li_ss_tl?ref_=Oct_DLandingS_PC_f9b023f0_NA&smid=ATVPDKIKX0DER&linkCode=sl1&tag=hyperk-20&linkId=0e5b7a4220a466b17817b9f3c242fb1f" features:@[@"With our most powerful motor for household machines, quickly blend virtually any whole-food ingredient with ease.",@"The 64-ounce Low-Profile Container is perfect for family meals and entertaining, while fitting comfortably under most kitchen cabinets.",@"With the Pulse feature, layer coarse chops over smooth purees for heartier recipes, such as chunky salsas or thick vegetable soups.",@"Ten variable speeds allow you to refine every texture with culinary precision, from the smoothest purees to the heartiest soups.",@"Electrical Ratings: 120 V, 50/60 Hz, 12 Amps"]];
    [self addFakeItemWithTitle:@"Instant Pot DUO Plus 3" price:@"$99.95" seller:@"by Instant Pot" image:@"https://images-na.ssl-images-amazon.com/images/I/716pog8j5xL._SL1500_.jpg" link:@"https://www.amazon.com/Instant-Pot-Plus-Programmable-Sterilizer/dp/B075CYMYK6/%20ref=as_li_ss_tl?smid=ATVPDKIKX0DER&pf_rd_p=d85771be-cc76-4586-8f1c-%20f7e5be2de34e&pf_rd_s=merchandised-%20search-3&pf_rd_t=101&pf_rd_i=384082011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=XH0P671DHKM%20V2WF8FHK3&linkCode=sl1&tag=hyperk-20&linkId=2ea111d251212655a0848cb7a0b503d8" features:@[@"Duo Plus Mini, the ideal companion to the Duo Plus 6 Quart, combines 9 kitchen appliances in 1, Pressure Cooker, Slow Cooker, Rice Cooker, Steamer, Sauté, Yogurt Maker, Sterilizer and Warmer. Prepares dishes up to 70% faster saving you time and energy in your busy lifestyle.",@"Features 13 Smart Programs – Soup/Broth, Meat/Stew, Bean/Chili, Sauté, Rice, Porridge, Steam, Slow Cook, Yogurt, Keep Warm, Sterilizer, Egg Maker, and Pressure Cook, your favorite dishes are as easy as pressing a button.",@"Built with the latest 3rd generation technology, dual pressure settings, 3 temperatures in Sauté and Slow Cook, up to 24 hour delay start, automatic Keep Warm up to 10 hours, and sound ON/OFF.",@"Stainless steel (18/8) inner cooking pot, food grade 304, no chemical coating, 3-ply bottom for even heat distribution, fully sealed environment traps the flavours, nutrients and aromas in the food.",@"UL and ULC certified, 10 safety mechanisms to provide users with added assurance and confidence, designed to eliminate many common errors."]];
    [self addFakeItemWithTitle:@"PetSafe Zoom Rotating Laser Cat Toy" price:@"$30.94" seller:@"by PetSafe" image:@"https://images-na.ssl-images-amazon.com/images/I/71neVxYo2dL._SL1500_.jpg" link:@"https://www.amazon.com/gp/product/B07CQL4WXT/ref=as_li_ss_tl?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=merchandised-search-6&pf_rd_r=J7TZHFFWNT6P8T8W05MY&pf_rd_t=101&pf_rd_p=d26bb5c3-d9a1-49f1-8fcc-f330f0e91b50&pf_rd_i=18108553011&linkCode=sl1&tag=hyperk-20&linkId=963b7925cf5de41e4ae013cdc29f0991" features:@[@"Multiple pet play: The PetSafe Zoom rotating laser cat toy uses two lasers that rotate 360 degrees to provide twice the amount of fun; multiple kitties can chase the dynamic laser patterns",@"Safe for pets: the Zoom features two Class IIIA lasers with a 5 mw Max power output for a safe play experience; Requires three alkaline AA batteries (sold separately)",@"Quiet movement: The Zoom operates with minimal electronic sounds so even the most timid of kitties can enjoy chasing the fun play patterns; for best performance, use only alkaline batteries",@"Hands-free operation: press the on/off button once and watch THE fun begin; the Zoom automatically shuts off after 15 minutes to prevent cats from being over-stimulated",@"Support FOR you: The Zoom is backed by a one year product warranty; call, chat or email with our expert US-based customer care specialists at 1-800-845-3274 or ccc3@petsafe.Net monday-saturday"]];
    [self addFakeItemWithTitle:@"Probiotic Everyday for Dogs" price:@"$8.29" seller:@"by VetriScience" image:@"https://images-na.ssl-images-amazon.com/images/I/81fvZTQmVEL._SL1500_.jpg" link:@"https://www.amazon.com/dp/B013JDM21O/ref=as_li_ss_tl?pf_rd_p=25308308-%20a064-4e50-871f-686becf9317a&pf_rd_s=merchandised-%20search-2&pf_rd_t=101&pf_rd_i=18108553011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=JRJNHAZW4%2022JBKP3Z7CX&linkCode=sl1&tag=hyperk-20&linkId=ad9521f7dc46b6cdf80b7180d87f319b" features:@[@"Probiotic Everyday contains probiotics, soluble fibers and prebiotics (Fructoligosaccharides) that support regularity.",@"Probiotics provide the added benefit of promoting immune system function. Probiotic Everyday is safe for daily, long term use.",@"Our Probiotic soft chews are veterinarian formulated and have a delicious duck flavor that dogs love.",@"Veterinarian Formulated. Veterinarian Recommended.",@"VetriScience products are manufactured in the U.S.A. and are backed by a 100% Satisfaction Guarantee."]];
    [self addFakeItemWithTitle:@"littleBits Marvel Avengers Hero Inventor Kit" price:@"$99.99" seller:@"by LittleBits" image:@"https://images-na.ssl-images-amazon.com/images/I/81z2GtRQ%2BFL._SL1500_.jpg" link:@"https://www.amazon.com/dp/B07BDZZRR3/ref=as_li_ss_tl?%20smid=ATVPDKIKX0DER&pf_rd_p=0b19d2d4-%20c76b-477f-8a36-56c6133fd5e2&pf_rd_s=merchandised-%20search-15&pf_rd_t=101&pf_rd_i=17911192011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=8WETRZ797%200BNNQBHV2DH&linkCode=sl1&tag=hyperk-20&linkId=b32c1434075aadf735d1ce418a9f99fe" features:@[@"Code your gauntlet to unleash 10 authentic Avengers sound effects or record your own hero battlecry.",@"Includes everything kids need to build and customize an interactive electronic Super hero gauntlet: electronic building blocks, LED Matrix, authentic Marvel sound effects bit, plastic pieces, stickers and battery.",@"Unlock hours and hours of STEAM (science, technology, engineering, art, math) learning with over 18 activities for Super hero kids to build, play and code.",@"Creative kids bring their imagination to life by personalizing their interactive Super hero gear with included sticker sheets and household items.",@"No grown-ups necessary: in-app step by step video instructions and troubleshooting guide kids through fun missions like stealth mode, speed Tracker, Super hero voice, and animator creator."]];
    [self addFakeItemWithTitle:@"LEGO Star Wars Tm Kessel Run Millennium Falcon" price:@"$169.95" seller:@"by LEGO" image:@"https://images-na.ssl-images-amazon.com/images/I/91ULkUW6CKL._SL1500_.jpg" link:@"https://www.amazon.com/dp/B0787MWTLS/ref=as_li_ss_tl?%20smid=ATVPDKIKX0DER&pf_rd_p=7a1c0026-ac31-40af-9e8e-%20e8b49eab0ed5&pf_rd_s=merchandised-%20search-15&pf_rd_t=101&pf_rd_i=17911189011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=FTBTGE42J%20E8BE6N2RXQP&linkCode=sl1&tag=hyperk-20&linkId=3fb6fc4fa143ab30b9ff2f66edc46a07" features:@[@"Build the legendary Kessel Run Millennium Falcon from the Solo: A Star Wars movie",@"Includes a Han Solo figure, Chewbacca figure, Qi’ra figure, plus Lando Calrissian and Quay Tolsite figures",@"Star Wars collectible also includes a Kessel droid and DD-BD droid",@"LEGO Star Wars model kit measures over 4” (11cm) high, 18” (48cm) long and 11” (30cm) wide",@"1414 pieces – LEGO brick building set for boys and girls age 9-14 LEGO Star Wars toys are compatible with all LEGO construction sets for creative building"]];
    [self addFakeItemWithTitle:@"Chow Crown Game Kids Electronic Spinning Crown Snacks" price:@"$14.88" seller:@"by Hasbro" image:@"https://images-na.ssl-images-amazon.com/images/I/910O3a0PInL._SL1500_.jpg" link:@"https://www.amazon.com/dp/B0772229CR/ref=as_li_ss_tl?%20smid=ATVPDKIKX0DER&pf_rd_p=7a1c0026-ac31-40af-9e8e-%20e8b49eab0ed5&pf_rd_s=merchandised-%20search-15&pf_rd_t=101&pf_rd_i=17911189011&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=FTBTGE42J%20E8BE6N2RXQP&linkCode=sl1&tag=hyperk-20&linkId=eb5461bd8a90202ed6503f7ea875a045" features:@[@"The Chow Crown electronic kids game is great family fun with a tasty twist. It's a great choice for family game night and get-togethers",@"Load up the forks; once the music starts, the snacks will begin to spin. Try to eat the spinning food before the music stops (snacks not included)",@"Get ready for lots of laughs as players try to catch the snacks! Players try to bite the food off the forks without using their hands",@"The hilarious Chow Crown game has 2 modes of play. Try to eat the most food before the music stops or amp the challenge by switching to longer game mode"]];
    [self addFakeItemWithTitle:@"LG 75SK8070PUA 75-Inch 4K Ultra HD" price:@"$1696.99" seller:@"by LG" image:@"https://images-na.ssl-images-amazon.com/images/I/91YWYJ9LlsL._SL1500_.jpg" link:@"https://www.amazon.com/LG-75SK8070PUA-75-Inch-Ultra-Smart/dp/B07BHPLP5Y/ref=as_li_ss_tl?ref_=Oct_DLandingS_PC_ff37b4f1_NA&smid=ATVPDKIKX0DER&linkCode=sl1&tag=hyperk-20&linkId=bb0a20cfef747e2734ee03c9da713615" features:@[@"G SUPER UHD TV with AI (Artificial Intelligence) ThinQ has the Google Assistant built in, so you can control compatible smart home devices using just your voice through the LG Magic Remote. Create a center for your smart home and beyond. Plus it works with Amazon Alexa devices (sold separately).",@"α7 Intelligent Processor enhances 4K HDR content for a truly cinematic experience. Enjoy a more lifelike picture with superior depth, sharpness, and remarkably accurate color.",@"Local dimming can brighten and dim independently, enhancing contrast and achieving deeper black levels for a rich, lifelike image.",@"4K Cinema HDR on LG SUPER UHD TV with AI ThinQ features comprehensive support of major high dynamic range formats including Dolby Vision, as well as HDR10 and HLG, both with LG’s advanced tone-mapping technology that provides scene-by-scene optimization.",@"Dolby Atmos is the same audio technology developed for state-of-the-art cinemas, with immersive sound that appears to come from everywhere, putting you in the middle of all the excitement."]];

    [self.resultsTable reloadData];
}

- (IBAction)scrollToTop:(id)sender {
    [self.resultsTable  scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)loadMore {
    self.itemPage++;
    if(self.searchField.text.length > 0)
        [self searchAmazon:self.searchField.text];
    else {
        [self searchAmazon:self.activeCategoryName];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
        [self.categoriesCollectionView.collectionViewLayout invalidateLayout];
}

- (void)addFakeItemWithTitle:(NSString*)title price:(NSString*)price seller:(NSString*)seller image:(NSString*)image link:(NSString*)link features:(NSArray*)featuresArr{
    NSMutableDictionary *item = [NSMutableDictionary new];
    item[@"title"] = title;
    item[@"price"] = price;
    item[@"seller"] = seller;
    item[@"image"] = image;
    item[@"link"] = link;
    NSString *features = @"";
    for(NSString *feature in featuresArr) {
        if(feature != nil) {
            if([features length] == 0) {
                features = [features stringByAppendingString:[NSString stringWithFormat:@"• %@",feature]];
            }else {
                features = [features stringByAppendingString:[NSString stringWithFormat:@"\n• %@",feature]];
            }
        }
    }
    item[@"features"] = features;
    [self.searchResults addObject:item];
}

- (void)performSearch {
    self.itemPage = 1;
    [self searchAmazon:self.searchField.text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(performSearch) name:kKeyboardNotificationActionSearchButton object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)searchAmazon:(NSString*)keyword {
    if(self.itemPage == 1)
        [self.searchResults removeAllObjects];
    if(!self.searchInProgress)
        [HProgressHUD showHUDSizeType:HProgressHUDSizeTypeBigWhite addedTo:self.hudContainerView animated:YES];
    self.searchInProgress = YES;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"Service"] = @"AWSECommerceService";
    parameters[@"Operation"] = @"ItemSearch";
    parameters[@"ResponseGroup"] = @"Medium";
    parameters[@"SearchIndex"] = self.activeCategory;
    parameters[@"Availability"] = @"Available";
    parameters[@"Keywords"] = [keyword URLEncode];
    parameters[@"AWSAccessKeyId"] = @"AKIAIO4ZFUAJBTZCRGRA";
    parameters[@"AssociateTag"] = @"hyperkey-20";
    parameters[@"ItemPage"] = [NSString stringWithFormat:@"%i",self.itemPage];
    parameters[@"Timestamp"] = [[dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    
    NSLog(@"%@",parameters);
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSString *strToSign = [NSString stringWithFormat:@"GET\nwebservices.amazon.com\n/onca/xml\n"];
    NSString *query = @"";
    int index = 0;
    for(NSString *keys in sortedKeys) {
        if(index == 0)
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@=%@",keys,parameters[keys]]];
        else
            query = [query stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",keys,parameters[keys]]];
        index++;
    }
    strToSign = [strToSign stringByAppendingString:query];
    NSString *strToHash = strToSign;
    NSString *salt = @"f0tf7mFDKwPEwwUjdwYzpEWLBqI7ZZqWeqdf7Bs0";
    NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
    NSData *paramData = [strToHash dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, paramData.bytes, paramData.length, hash.mutableBytes);
    NSString *base64Hash = [hash base64Encoding];
    query = [query stringByAppendingString:[NSString stringWithFormat:@"&Signature=%@",base64Hash]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://webservices.amazon.com/onca/xml?%@",query]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                        if([newStr containsString:@"SignatureDoesNotMatch"]) {
                                                            newStr = nil;
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [self searchAmazon:keyword];
                                                            });
                                                            return;
                                                        }
                                                        NSLog(@"%@",newStr);
                                                        NSData* dataXml = [newStr dataUsingEncoding:NSUTF8StringEncoding];
                                                        NSError *error = nil;
                                                        NSDictionary *dict = [XMLReader dictionaryForXMLData:dataXml
                                                                                                     options:XMLReaderOptionsProcessNamespaces
                                                                                                       error:&error];
                                                        if(dict[@"ItemSearchResponse"][@"Items"][@"Item"] != nil) {
                                                            NSArray *items = dict[@"ItemSearchResponse"][@"Items"][@"Item"];
                                                            for(NSDictionary *dic in items) {
                                                                NSMutableDictionary *item = [NSMutableDictionary new];
                                                                item[@"title"] = dic[@"ItemAttributes"][@"Title"][@"text"];
                                                                item[@"price"] = dic[@"ItemAttributes"][@"ListPrice"][@"FormattedPrice"][@"text"];
                                                                if(dic[@"ItemAttributes"][@"Manufacturer"][@"text"] != nil)
                                                                    item[@"seller"] = [NSString stringWithFormat:@"by %@",dic[@"ItemAttributes"][@"Manufacturer"][@"text"]];
                                                                else
                                                                    item[@"seller"] = @"";
                                                                item[@"image"] = dic[@"MediumImage"][@"URL"][@"text"];
                                                                item[@"link"] = [dic[@"DetailPageURL"][@"text"] stringByReplacingOccurrencesOfString:@"hyperkey-20" withString:@"hyperk-20"];
                                                                NSString *features = @"";
                                                                if(dic[@"ItemAttributes"][@"Feature"] != [NSNull null]) {
                                                                    if([dic[@"ItemAttributes"][@"Feature"] isKindOfClass:[NSArray class]]) {
                                                                        NSArray *featuresArr = dic[@"ItemAttributes"][@"Feature"];
                                                                        for(NSDictionary *feature in featuresArr) {
                                                                            if(feature != nil) {
                                                                                if([features length] == 0) {
                                                                                    features = [features stringByAppendingString:[NSString stringWithFormat:@"• %@",feature[@"text"]]];
                                                                                }else {
                                                                                    features = [features stringByAppendingString:[NSString stringWithFormat:@"\n• %@",feature[@"text"]]];
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    item[@"features"] = features;
                                                                }
                                                                item[@"features"] = features;
                                                                [self.searchResults addObject:item];
                                                            }
                                                            dataXml = nil;
                                                            newStr = nil;
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.searchInProgress = NO;
                                                                if(self.moreButton == nil && self.searchResults.count > 0) {
                                                                    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
                                                                    self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
                                                                    [self.moreButton setTitle:@"Load More" forState:UIControlStateNormal];
                                                                    [self.moreButton setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
                                                                    [self.moreButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
                                                                    [footerView addSubview:self.moreButton];
                                                                    self.resultsTable.tableFooterView = footerView;
                                                                }
                                                                [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
                                                                [self.resultsTable reloadData];
                                                                if(self.searchResults.count <= 10){
                                                                    NSIndexPath* ipath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                                    [self.resultsTable scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                                                }
                                                            });
                                                            
                                                        }else {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [self.searchResults removeAllObjects];
                                                                [self.resultsTable reloadData];
                                                                self.searchInProgress = NO;
                                                                [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
                                                            });
                                                        }
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if(self.searchResults.count == 0) {
                                                                self.upButton.hidden = YES;
                                                                [self.moreButton removeFromSuperview];
                                                                self.moreButton = nil;
                                                                self.empty.hidden = NO;
                                                            }else {
                                                                self.upButton.hidden = NO;
                                                                self.empty.hidden = YES;
                                                            }
                                                        });
                                                    }else {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            self.searchInProgress = NO;
                                                            [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
                                                        });
                                                    }
                                                }];
    [dataTask resume];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AmazonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AmazonTableViewCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle bundleForClass:NSClassFromString(@"AmazonTableViewCell")] loadNibNamed:@"AmazonTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.share.tag = (int)indexPath.row;
    [cell.share removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.share addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.itemTitle.text = [self.searchResults objectAtIndex:indexPath.row][@"title"];
    cell.itemDesc.text = [self.searchResults objectAtIndex:indexPath.row][@"seller"];
    cell.itemPrice.text = [self.searchResults objectAtIndex:indexPath.row][@"price"];
    [cell.imageIcon sd_setImageWithURL:[NSURL URLWithString:[self.searchResults objectAtIndex:indexPath.row][@"image"]] placeholderImage:nil options: SDWebImageRetryFailed | SDWebImageContinueInBackground ];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    AmazonTableViewCell *cellAmazon = (AmazonTableViewCell*)cell;
    cellAmazon.imageIcon.image = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 106;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AmazonPageViewController *infoVC = [[AmazonPageViewController alloc] initWithNibName:NSStringFromClass([AmazonPageViewController class]) bundle:[NSBundle bundleForClass:NSClassFromString(@"AmazonPageViewController")]];
    infoVC.item = [self.searchResults objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:infoVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if(![self isRowZeroVisible] && self.upButton.hidden) {
        self.upButton.hidden = NO;
    }else if([self isRowZeroVisible] && !self.upButton.hidden){
        self.upButton.hidden = YES;
    }
}

-(BOOL)isRowZeroVisible {
    NSArray *indexes = [self.resultsTable indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == 1) {
            return YES;
        }
    }
    return NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL
{
    image = [self imageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    return image;
}

- (IBAction)shareAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    int index = (int)btn.tag;
    NSString *link = [self.searchResults objectAtIndex:index][@"link"];
    NSString *name = [self.searchResults objectAtIndex:index][@"title"];
    if(link != nil) {
        [self insertLinkWithURLString:link title:@"" featureType:self.featureType completion:nil];
    }
}

- (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)targetSize; {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        } else {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else {
            if (widthFactor < heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
 {
 CGRect scaledImageRect = CGRectZero;
 
 CGFloat aspectWidth = newSize.width / image.size.width;
 CGFloat aspectHeight = newSize.height / image.size.height;
 CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );
 
 scaledImageRect.size.width = image.size.width * aspectRatio;
 scaledImageRect.size.height = image.size.height * aspectRatio;
 scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
 scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
 
 UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
 [image drawInRect:scaledImageRect];
 UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 return scaledImage;
 }*/


#pragma mark - UITextFieldIndirectDelegate

- (UITextField *)forceFindSearchTextField {
    return self.searchField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        self.itemPage = 1;
        [self searchAmazon:textField.text];
    }
    return YES;
}


#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    
    NSString *string = [self.categoriesArray objectAtIndex:indexPath.item];
    
    CGRect frame = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.categoriesCollectionView.frame.size.height)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}
                                        context:nil];
    size.width = frame.size.width + 29;
    size.height = collectionView.frame.size.height;
    
    return size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoriesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GifCategoryCell class]) forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCategoryCell *cell = (GifCategoryCell *)aCell;
    cell.titleLabel.text = [self.categoriesArray objectAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.activeCategory = [self.categoriesArrayIds objectAtIndex:indexPath.item];
    self.activeCategoryName = [self.categoriesArray objectAtIndex:indexPath.item];
    if(self.searchField.text.length > 0)
        [self searchAmazon:self.searchField.text];
    else {
        self.itemPage = 1;
        if([self.activeCategory isEqualToString:@"All"]) {
            [self showEmpty];
        }else
            if([self.activeCategoryName isEqualToString:@"Electronics"])
                [self searchAmazon:@"computer"];
            else
                [self searchAmazon:self.activeCategoryName];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
