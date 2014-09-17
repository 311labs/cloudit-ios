# CloudIt

CloudIt-IOS is an IOS SDK for accessing 311Labs CloudIt solutions.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

    pod 'CloudIt', :git => 'https://github.com/311labs/cloudit-ios.git
    
    There are some issues with google sdk not being included correctly.
    Framework Search Path
    "$(PODS_ROOT)/googleplus-ios-sdk" "recursive"
    
## Example Usage

    // initialize the singleton to the correct host normally in your appdelegate at start
    self.cloudit = [[CloudItService shared] initWithHost:@"https://pdir.tv"];
    // recommend allowing duplicate requests for now until we sort out bugs
    [self.cloudit setDuplicateRequestPolicy:DUP_REQ_ALLOW];
    // recommend doing a dummy call to the site to get CSRF tokens
    // you can ignore the results
    [[CloudItAccount shared] checkIfAuthenticated:^(CloudItResponse *response) {
        // check authenticated
        
    } onFailure:^(NSError *error) {
        // request failed?
    }];
    
## Author

istarnes, ian@311labs.com

## License

CloudIt is available under the MIT license. See the LICENSE file for more info.

