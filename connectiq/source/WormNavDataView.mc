using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.Timer;
using Utils;
using Trace;

class WormNavDataView extends  WatchUi.View {

    hidden var data = new [4];
    private var activity;
    private var timer;

    const avgChar = StringUtil.utf8ArrayToString([0xC3,0x98]);

    function initialize(activityArg) {
        View.initialize();
        activity = activityArg;
    }

    function onShow() {
        timer = new Timer.Timer();
        timer.start(method(:refresh), 1000, true);      
    }

    function refresh() {
        WatchUi.requestUpdate();
    }

    function onHide() {
        timer.stop();
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        System.println("DataView.onUpdate");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        if (activity.getState() != ACTIVITY_RUNNING) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(15);
            dc.drawCircle(Transform.pixelWidth2, Transform.pixelHeight2, Transform.pixelWidth2);
        }

        // draw lines for 4 data fields
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        var y1 = Transform.pixelHeight3 / 2;
        dc.drawLine(0, y1, Transform.pixelWidth, y1);
        var y2 = Transform.pixelHeight3;
        dc.drawLine(0, y2, Transform.pixelWidth, y2);
        dc.drawLine(Transform.pixelWidth2, y1, Transform.pixelWidth2, y2);

        if(Activity.getActivityInfo()!=null) {
            if( Activity.getActivityInfo().elapsedDistance!= null) {
               data[0] = Activity.getActivityInfo().elapsedDistance/1000;
            }
            if(Activity.getActivityInfo().elapsedTime!=null) {
               data[1] = Activity.getActivityInfo().timerTime;
            }
            if(Activity.getActivityInfo().averageSpeed!=null) {
               data[2] = Activity.getActivityInfo().averageSpeed;
               //data[2]=Utils.speedToPace(data[2]);
               //data[2] = Utils.convertSpeedToPace(data[2]);
            }
            if(Activity.getActivityInfo().currentHeartRate!=null) {
               data[3] = Activity.getActivityInfo().currentHeartRate;
            }
        }

        var x= Transform.pixelWidth2;
        drawField(dc, "Timer", data[1]!=null? Utils.msToTime(data[1]) : null,x,0);
        x = Transform.pixelWidth/4;
        drawField(dc, "Distance", data[0]!=null? data[0].format("%.2f") : null, x, y1);
        x = 3*Transform.pixelWidth/4;
        StringUtil.utf8ArrayToString([0xC2,0xB0]);
        //drawField(dc, avgChar + " Pace",Utils.printPace(data[2]) , x, y1);
        drawField(dc, avgChar + " Pace", data[2]!=null? Utils.convertSpeedToPace(data[2]) : null , x, y1);
        x = Transform.pixelWidth2;
        drawField(dc, "Heart Rate", data[3]!=null? data[3] : null, x, y2);
    }

    function drawField(dc, label, value, x, y) {
        //var offset = dc.getFontHeight( Graphics.FONT_MEDIUM );
        var offset = 0.5*dc.getFontAscent( Graphics.FONT_MEDIUM );

        if(value==null) {
            value="--";
        }
        if( label == null ) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y+offset, Graphics.FONT_NUMBER_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y+offset , Graphics.FONT_MEDIUM, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y + offset + dc.getFontDescent( Graphics.FONT_MEDIUM )+ 0.5*dc.getFontHeight( Graphics.FONT_NUMBER_MEDIUM ), Graphics.FONT_NUMBER_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        return;
    }
}
