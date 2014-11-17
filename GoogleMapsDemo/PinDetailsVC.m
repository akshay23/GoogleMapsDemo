//
//  PinDetailsVC.m
//  MyFavPins
//
//  Created by Akshay Bharath on 11/7/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "PinDetailsVC.h"

@interface PinDetailsVC ()

@property (strong, nonatomic) GMSMapView *mapView;

@end

@implementation PinDetailsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Address label and button stuff
    self.lblAddress.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblAddress.numberOfLines = 4;
    self.btnDelete.layer.cornerRadius = 4;
    self.btnDelete.layer.borderWidth = 1;
    self.btnDelete.layer.borderColor = [UIColor blueColor].CGColor;
    self.btnSaveChanges.layer.cornerRadius = 4;
    self.btnSaveChanges.layer.borderWidth = 1;
    self.btnSaveChanges.layer.borderColor = [UIColor blueColor].CGColor;
    
    // Set up Google Maps
    // Initialize google map view with camera position
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.pinObject.latitude doubleValue] longitude:[self.pinObject.longitude doubleValue] zoom:16 bearing:0 viewingAngle:0];
    self.mapView = [GMSMapView mapWithFrame:self.mapContainer.bounds camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = NO;
    self.mapView.delegate = self;
    [self.mapView setMinZoom:12 maxZoom:18];

    // Get the pin details
    self.txtPinName.text = self.pinObject.name;
    self.lblAddress.text = self.pinObject.address;
    self.lblLatitude.text = [self.pinObject.latitude stringValue];
    self.lblLongitude.text = [self.pinObject.longitude stringValue];
    
    // Add views to main view
    [self.mapContainer addSubview:self.mapView];
    self.mapContainer.frame = CGRectMake(0, self.mapContainer.frame.origin.y, self.mapContainer.frame.size.width, self.mapContainer.frame.size.height);
    [self.view addSubview:self.mapContainer];
    
    // Create marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([self.pinObject.latitude doubleValue], [self.pinObject.longitude doubleValue]);
    marker.title = self.pinObject.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    // Add action for Done button
    [self.txtPinName addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // Gesture recognizer to hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deletePin:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                     message:@"Are you sure you want to delete this pin?"
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    
    [alert show];
}

- (IBAction)saveChanges:(id)sender
{
    if (self.txtPinName.text && ![self.txtPinName.text isEqualToString:@""])
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"dateCreated=%@", self.pinObject.dateCreated];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyPin" inManagedObjectContext:self.fetchedResultsController.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:pred];
        
        NSError *error = nil;
        NSArray *result = [self.fetchedResultsController.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSManagedObject *pin = (NSManagedObject *)[result objectAtIndex:0];
        [pin setValue:self.txtPinName.text forKey:@"name"];
        
        NSError *saveError = nil;
        if (![pin.managedObjectContext save:&saveError]) {
            NSLog(@"Unable to save changes for pin.");
            NSLog(@"%@, %@", saveError, saveError.localizedDescription);
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucess!" message:@"Changes successfully saved." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Save!" message:@"Pin name cannot be empty" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:self.indexPathOfObject];
        [self.fetchedResultsController.managedObjectContext deleteObject:managedObject];
        [self.fetchedResultsController.managedObjectContext save:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Hide keyboard when user taps something
-(void)dismissKeyboard
{
    [self.txtPinName resignFirstResponder];
}

// Hide keyboard when 'Done' is tapped
- (void)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

@end
