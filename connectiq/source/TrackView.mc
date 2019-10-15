using Toybox.WatchUi;
using Toybox.Position;
using Toybox.Timer;
using Toybox.Graphics;
using Transform;
using Trace;

class TrackView extends WatchUi.View {

    private var activity;
    private var trackRef = null;
    private var show = false;
    private var gpsSignal = Position.QUALITY_NOT_AVAILABLE;
    private var cursorSizePixel;
    private var timer;

    function initialize(activityArg) {
        System.println("TrackView.initialize()");
        View.initialize();
        activity = activityArg;
        Trace.reset();
    }

    private function draw_bread_crumbs(dc) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        var xy_pos;

        if(Transform.northHeading || Transform.centerMap) {
            for(var i=0; i < Trace.pos_nelements; i+=1) {
                var j = (Trace.pos_start_index +i) % Trace.BUFFER_SIZE;
                xy_pos = Transform.xy_2_screen(Trace.x_array[j], Trace.y_array[j]);
                dc.fillCircle(xy_pos[0],xy_pos[1] , 3);
            }
        }
        else {
           for(var i=0; i < Trace.pos_nelements; i+=1) {
                var j = (Trace.pos_start_index +i) % Trace.BUFFER_SIZE;
                xy_pos = Transform.xy_2_rot_screen(Trace.x_array[j], Trace.y_array[j]);
                dc.fillCircle(xy_pos[0],xy_pos[1] , 3);
           }
        }

    }

    private function drawPauseIndicator(dc) {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(15);
        dc.drawCircle(Transform.pixelWidth2, Transform.pixelHeight2, Transform.pixelWidth2);
    }

    private function draw_scale(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        dc.drawLine(Transform.scale_x1,Transform.scale_y1,Transform.scale_x1,Transform.scale_y2);
        dc.drawLine(Transform.scale_x1,Transform.scale_y2,Transform.scale_x2,Transform.scale_y2);
        dc.drawLine(Transform.scale_x2,Transform.scale_y2,Transform.scale_x2,Transform.scale_y1);
        dc.drawText(Transform.pixelWidth2, Transform.scale_y2-dc.getFontHeight( Graphics.FONT_MEDIUM ),
            Graphics.FONT_MEDIUM , Transform.formatScale(Transform.refScale), Graphics.TEXT_JUSTIFY_CENTER);

    }

    private function drawGpsSignal(dc) {
        switch (gpsSignal) {
            case Position.QUALITY_NOT_AVAILABLE:
            case Position.QUALITY_LAST_KNOWN:
                dc.setPenWidth(4);
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(Transform.gps_signal_x, Transform.gps_signal_y, Transform.gps_signal_size);
                return;
            case Position.QUALITY_POOR:
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                break;
            case Position.QUALITY_USABLE:
                break;
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                break;
            case Position.QUALITY_GOOD:
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                break;
        }
        dc.fillCircle(Transform.gps_signal_x, Transform.gps_signal_y, Transform.gps_signal_size);
    }


    private function draw_activity_info(dc) {
        var yOffset = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND ? 15 : 0;
        var y = 0.5 * Graphics.getFontAscent(Graphics.FONT_MEDIUM);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        if (activity.getState() == ACTIVITY_NOT_START) {
            dc.drawText(Transform.pixelWidth2, yOffset + 2*y, Graphics.FONT_MEDIUM, 
                "Press START", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        if (Activity.getActivityInfo().elapsedDistance!= null) {
            var data = Activity.getActivityInfo().elapsedDistance/1000;
            var distance = "Dist: " + data.format("%.2f");
            dc.drawText(Transform.pixelWidth2, yOffset + y, Graphics.FONT_MEDIUM , distance, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        if (Activity.getActivityInfo().elapsedTime!=null) {
            var data = Activity.getActivityInfo().timerTime;
            var time = "Time: " + Utils.msToTime(data);
            dc.drawText(Transform.pixelWidth2, yOffset + 3*y, Graphics.FONT_MEDIUM , time, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }


    private function draw_track(dc) {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        var xy_pos1;
        var xy_pos2;

        var xya = $.track.xyArray;

        var step = 2;

        var i=0;
        if(Transform.northHeading || Transform.centerMap || Transform.isTrackCentered) {
            xy_pos1 = Transform.xy_2_screen(xya[i],xya[i+1]);
            xy_pos2 = Transform.xy_2_screen(xya[i+step],xya[i+step+1]);
        } else {
            xy_pos1 = Transform.xy_2_rot_screen(xya[i],xya[i+1]);
            xy_pos2 = Transform.xy_2_rot_screen(xya[i+step],xya[i+step+1]);
        }
        dc.drawLine(xy_pos1[0],xy_pos1[1],xy_pos2[0],xy_pos2[1]);

        for(i = step; i < xya.size()-step-1; i+=step ) {
            xy_pos1 = xy_pos2;
            if(Transform.northHeading || Transform.centerMap || Transform.isTrackCentered) {
                xy_pos2 = Transform.xy_2_screen(xya[i+step],xya[i+step+1]);
            }
            else {
                xy_pos2 = Transform.xy_2_rot_screen(xya[i+step],xya[i+step+1]);
            }
            dc.drawLine(xy_pos1[0],xy_pos1[1],xy_pos2[0],xy_pos2[1]);
        }

    }

    private function draw_trace(dc) {

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        var sf = 2*cursorSizePixel;

        var heading;
        var dx1;
        var dy1;
        var dx2;
        var dy2;
        var dx3;
        var dy3;

        if(Transform.northHeading || Transform.centerMap) {
            heading = Transform.heading_smooth;
            dx1= cursorSizePixel*Transform.sin_heading_smooth;
            dy1=-cursorSizePixel*Transform.cos_heading_smooth;
        }
        else {
            heading = 0;
            dx1=0;
            dy1=-cursorSizePixel;
        }

        dx2= sf*Math.sin(heading+Transform.ANGLE_R);
        dy2=-sf*Math.cos(heading+Transform.ANGLE_R);
        dx3= sf*Math.sin(heading+Transform.ANGLE_L);
        dy3=-sf*Math.cos(heading+Transform.ANGLE_L);

        var xy_pos = Transform.xy_2_screen(Transform.x_pos, Transform.y_pos);

        //dc.drawCircle(xy_pos[0], xy_pos[1], 3);

        dc.setPenWidth(3);
        dc.drawLine(xy_pos[0]+dx1, xy_pos[1]+dy1, xy_pos[0]+dx2, xy_pos[1]+dy2);
        dc.drawLine(xy_pos[0]+dx2, xy_pos[1]+dy2, xy_pos[0]-dx1, xy_pos[1]-dy1);
        dc.drawLine(xy_pos[0]-dx1, xy_pos[1]-dy1, xy_pos[0]+dx3, xy_pos[1]+dy3);
        dc.drawLine(xy_pos[0]+dx3, xy_pos[1]+dy3, xy_pos[0]+dx1, xy_pos[1]+dy1);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillCircle(Transform.compass_x,Transform.compass_y,Transform.compass_size);

        if(Transform.northHeading || Transform.centerMap) {
            dx1 = - 0.5*Transform.compass_size;
            dx2 = 0;
            dx3 = -dx1;
            dy1 = 0;
            dy2 = - Transform.compass_size;
            dy3 = 0;
        } else {
            dx1 = -0.5*Transform.compass_size*Transform.cos_heading_smooth;
            dy1 = +0.5*Transform.compass_size*Transform.sin_heading_smooth;
            dx2 = -Transform.compass_size*Transform.sin_heading_smooth;
            dy2 = -Transform.compass_size*Transform.cos_heading_smooth;
            dx3 =  -dx1;
            dy3 =  -dy1;
        }

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        var points = [[Transform.compass_x + dx1, Transform.compass_y + dy1],
                      [Transform.compass_x - dx2, Transform.compass_y - dy2],
                      [Transform.compass_x + dx3, Transform.compass_y + dy3]];
        dc.fillPolygon(points);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        points = [[Transform.compass_x + dx1, Transform.compass_y + dy1],
                  [Transform.compass_x + dx2, Transform.compass_y + dy2],
                  [Transform.compass_x + dx3, Transform.compass_y + dy3]];
        dc.fillPolygon(points);

        if(Trace.breadCrumbDist > 0) {
            draw_bread_crumbs(dc);
        }
    }


    // Load your resources here
    function onLayout(dc) {
        Transform.setPixelDimensions(dc.getWidth(), dc.getHeight());
        cursorSizePixel=Transform.pixelWidth*Transform.SCALE_PIXEL*0.5;
    }

    function refresh() {
        WatchUi.requestUpdate();
    }

    function onShow() {
        System.println("onShow()");
        show = true;
        View.onShow();
        timer = new Timer.Timer();
        timer.start(method(:refresh), 1000, true);      
        if($.track==null) {
            Transform.setZoomLevel(5);
        }
    }

    function onHide() {
        timer.stop();
        show = false;
    }

    // Update the view
    function onUpdate(dc) {
        if (trackRef != $.track) {
            Transform.onTrackChange();
            trackRef = $.track;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        if (activity.getState() != ACTIVITY_RUNNING) {
            drawPauseIndicator(dc);
        }

        if(track!=null) {
            draw_track(dc);
        }

        if(Transform.x_pos != null) {
            draw_trace(dc);
        }

        draw_activity_info(dc);
        draw_scale(dc);
        drawGpsSignal(dc);
    }

    function onPosition(info) {
        if (show) {
            Transform.isTrackCentered = false;
            Transform.setPosition(info);
            gpsSignal = info.accuracy;
        }
    }
}
