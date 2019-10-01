using Toybox.WatchUi;

class WormNavSaveMenuDelegate extends WatchUi.MenuInputDelegate {

    private var activity;

    function initialize(lapTrackerArg) {
        MenuInputDelegate.initialize();
        activity = lapTrackerArg;
    }
    
    function onMenuItem(item) {
        activity.exit(item == :save);
        return true;
    }

}
