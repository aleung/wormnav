using Toybox.WatchUi;
using Toybox.System;
using Trace;

class WormNavMainMenuDelegate extends WatchUi.MenuInputDelegate {

    private var activity;

    function initialize(ActivityArg) {
        MenuInputDelegate.initialize();
        activity = ActivityArg;
    }

    function onMenuItem(item) {
        if (item == :delete) {
            if(track!=null) {
                track=null;
                Trace.reset();
            }
            return true;
        }
        if (item == :north) {
            Transform.northHeading = !Transform.northHeading;
            Application.getApp().setProperty("northHeading", Transform.northHeading);
            return true;
        }
        if (item == :center) {
            Transform.centerMap = !Transform.centerMap;
            Application.getApp().setProperty("centerMap", Transform.centerMap);
            return true;

        }
        if (item == :autolap) {
            var autolapMenu = new Rez.Menus.AutolapMenu();
            autolapMenu.setTitle("Autolap <" + activity.getAutolapDistanceStr() + ">");
            WatchUi.pushView(autolapMenu, new WormNavAutolapMenuDelegate(activity), WatchUi.SLIDE_UP);
            return true;
        }
        if (item == :breadCrumbs) {
            var breadCrumbsMenu = new Rez.Menus.BreadCrumbsMenu();
            breadCrumbsMenu.setTitle("Bread crumbs <" + Trace.getBreadCrumbDistStr() + ">");
            WatchUi.pushView(breadCrumbsMenu, new WormNavBreadCrumbsMenuDelegate(), WatchUi.SLIDE_UP);
            return true;
        }


        return false;
    }
}