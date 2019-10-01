using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Attention;

class LapView extends WatchUi.View {

    private var activity;

    function initialize(activityArg) {
        View.initialize();
        activity = activityArg;
    }

    function onShow() {
        new Timer.Timer().start(method(:attention), 1000, false);      
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getFontHeight(Graphics.FONT_LARGE), 
            Graphics.FONT_LARGE, 
            "Lap " + activity.lapCounter, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM)/2, 
            Graphics.FONT_NUMBER_HOT, 
            Utils.msToTimeWithDecimals(activity.lapTime.toLong()), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function dismiss() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function attention() {
        if (Attention has :vibrate) {
            Attention.vibrate( [new Attention.VibeProfile(50, 500)] );
        }
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_LAP );
        }
        new Timer.Timer().start(method(:dismiss), 9000, false);      
    }
}

// TODO: add Delegate
