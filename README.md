# Melbourne Historical Sights

The application contains information about Melbourne historical sights, allows to add new sights and notifies the user in background when they are close to a sight. 


### Home Screen - MapViewController
 * The map shows markers of historical sights.
 * Tapping on the marker makes callout appears.
 * The callout contains a small image of the sight, the title and description.
 * Tapping on the callout opens SightDetailViewController.
 * **Sights** button on the navigation bar leads to SightsTableViewController.
 
### Sight List Screen - SightsTableViewController
* The table view shows a list of sights.
* Tapping on a sight takes the user back to the map and focuses on the sight.
* Sights can be searched, search bar appears by swiping down.
* Each sight can be deleted by swiping left and clicking **Delete** button.
* The list can be sorted by A-Z or Z-A alphabetical orders.
* **+** button on the navigation bar leads to EditSightViewController.

### Sight Detail Screen - SightDetailViewController
* This screen displays the image, title, description and location of a sight.
* **Edit** button on the navigation bar lead to EditSightViewController.

### Add Sight Screen - EditSightViewController
* The screen allows user to add/change the image, title, description, marker and set location.

## Acknowledgement
Most of the solutions in the application are derived from the [FIT5140: Advanced mobile systems](http://www.monash.edu/pubs/handbooks/units/FIT5140.html) tutorial materials. The other external resources, the code is used from, are cited as links in comments.

### Other resources used in the project:
 - Descriptions of default sights taken from [www.visitvictoria.com](https://www.visitvictoria.com/Regions/Melbourne/Things-to-do/History-and-heritage) and Wikipedia.

 - Images of default sights taken from corresponding Wikipedia pages.

 - Glyph building icons made by [Surang](https://www.flaticon.com/authors/surang) from [www.flaticon.com](https://www.flaticon.com).
 
 - Location pin icon in SightDetialViewController made by [Freepik](https://www.freepik.com) from [www.flaticon.com](https://www.flaticon.com).
 
 - App icon derived from [image](https://www.shutterstock.com/image-vector/australia-melbourne-cite-landscape-modern-panorama-638907502) made by [nastyrekh](https://www.shutterstock.com/g/nastyrekh).


