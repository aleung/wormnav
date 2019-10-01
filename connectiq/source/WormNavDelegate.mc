using Toybox.WatchUi;
using Transform;


class WormNavDelegate extends WatchUi.BehaviorDelegate {

    private var dataView;
    private var activity;
    private var views;  // array: [TrackView, DataView]
    private var currentView = 0;

    function initialize(activityArg, viewsArg) {
        BehaviorDelegate.initialize();
        activity = activityArg;
        views = viewsArg;
    }

    function onTap(clickEvent) {
        System.println("onTap:" + clickEvent.getType());
        toggleView();
        return true;
    }

    // do not use onSelect() because we don't want to toggleStart when tap on touch screen
    function onKey(keyEvent) {
        System.println("onKey:" + keyEvent.getKey());
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            toggleStart();
            return true;
        }
        return false;
    }

    function onNextPage() {
        System.println("onNextPage()");
        if (currentView == 0) {
            Transform.zoomOut();
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onPreviousPage() {
        System.println("onPreviousPage()");
        if (currentView == 0) {
            Transform.zoomIn();
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onBack() {
        System.println("onBack()");
        switch (activity.getState()) {
            case ACTIVITY_NOT_START:
                activity.exit(false);
                break;
            case ACTIVITY_PAUSE:
                WatchUi.pushView(new Rez.Menus.SaveMenu(), new WormNavSaveMenuDelegate(activity), WatchUi.SLIDE_RIGHT);
                break;
            case ACTIVITY_RUNNING:
                toggleView();
                break;
        }
        return true;
    }

    function onMenu() {
        System.println("onMenu()");
        var menu = new WatchUi.Menu();
        menu.setTitle("Main Menu");

        var mapOrientation = Transform.northHeading ? "[north]/heading" : "north/[heading]";
        menu.addItem(WatchUi.loadResource(Rez.Strings.main_menu_label_1) + mapOrientation, :north);

        menu.addItem(WatchUi.loadResource(Rez.Strings.main_menu_label_2) + activity.getAutolapDistanceStr(), :autolap);
        menu.addItem(WatchUi.loadResource(Rez.Strings.main_menu_label_3) + Trace.getBreadCrumbDistStr(), :breadCrumbs);

        var centerMap = Transform.centerMap ? "[on]/off" : "on/[off]";
        menu.addItem(WatchUi.loadResource(Rez.Strings.main_menu_label_4) + centerMap, :center);

        menu.addItem(Rez.Strings.main_menu_label_5, :delete);

        WatchUi.pushView(menu, new WormNavMainMenuDelegate(activity), WatchUi.SLIDE_LEFT);
        return true;
    }

    private function toggleStart() {
        activity.toggleStart();
        WatchUi.requestUpdate();
    }

    private function toggleView() {
        currentView = (currentView == 0) ? 1 : 0;
        WatchUi.switchToView(views[currentView], self, WatchUi.SLIDE_IMMEDIATE);
    }

}
