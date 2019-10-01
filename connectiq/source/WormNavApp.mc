using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Position;
using Trace;
using Transform;

// --- global variables ---

var track = null;

// --- main application ---

class WormNavApp extends Application.AppBase {

    var activity;
    var trackView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        System.println("App.onStart");

        var data= Application.getApp().getProperty("trackData");
        if (data!=null) {
            System.println("load data from property store");
            $.track = new TrackModel(data);
        }

        if(Application.getApp().getProperty("northHeading")!=null) {
            Transform.northHeading=Application.getApp().getProperty("northHeading");
        }

        if(Application.getApp().getProperty("centerMap")!=null) {
            Transform.centerMap=Application.getApp().getProperty("centerMap");
        }

        if(Application.getApp().getProperty("breadCrumbDist")!=null) {
            Trace.breadCrumbDist = Application.getApp().getProperty("breadCrumbDist");
        }

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    // Return the initial view of your application here
    function getInitialView() {
        activity = new WormNavActivity();
        trackView = new TrackView(activity);
        var viewDelegate = new WormNavDelegate(activity, [trackView, new WormNavDataView(activity)]);
        var phoneMethod = method(:onPhone);
        if(Communications has :registerForPhoneAppMessages) {
            Communications.registerForPhoneAppMessages(phoneMethod);
        }
        return [trackView, viewDelegate];
    }

    function onPhone(msg) {
        System.println("onPhone(msg)");
        $.track = new TrackModel(msg.data);
        try {
            Application.getApp().setProperty("trackData", msg.data);
            WatchUi.requestUpdate();
        }
        catch( ex ) {
            System.println(ex.getErrorMessage());
            System.exit();
        }
    }

    function onPosition(info) {
        try {
            Trace.new_pos(info.position.toRadians()[0],info.position.toRadians()[1]);
            var activity = Application.getApp().activity;
            if (activity.isAutolap()) {
                WatchUi.pushView(new LapView(activity), null, WatchUi.SLIDE_IMMEDIATE);
            }
            Application.getApp().trackView.onPosition(info);
        } catch(e) {
            e.printStackTrace();
            System.exit();
        }
    }

}
