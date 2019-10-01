using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Attention;

class LapView extends WatchUi.View {

    var showing = false;

    private var activity;
    private var timer;

    function initialize(activityArg) {
        View.initialize();
        activity = activityArg;
    }

    function onShow() {
        showing = true;
        if (Attention has :vibrate) {
            Attention.vibrate( [new Attention.VibeProfile(50, 500)] );
        }
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_LAP );
        }
        timer = new Timer.Timer();
        timer.start(method(:dismiss), 6000, false);              
    }

    function onHide() {
        showing = false;
        timer.stop();
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
}

// TODO: add its own Delegate, no response to START right now
