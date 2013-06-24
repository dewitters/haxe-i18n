package com.roxstudio.i18n;

import nme.Assets;

#if haxe3

private typedef Hash<T> = Map<String, T>;
private typedef IntHash<T> = Map<Int, T>;

#end

class Global {

    public static inline var DEFAULT = "default";
    public static var supportedLocales(default, null): Array<String> = I18n.getSupportedLocales();
    public static var currentLocale(default, set_currentLocale) : String = DEFAULT;

    private static var map: IntHash<String> = null;
    private static var assetsDir: String = I18n.getAssetsDir();
    private static var absenceResources: Hash<Int> = new Hash();
    private static var listeners: Hash<Void -> Void> = new Hash();

    private function new() {
    }

    #if haxe3 @:noCompletion #end
    public static inline function str(id: Int) : String {
        return map.get(id);
    }

    #if haxe3 @:noCompletion #end
    public static inline function res(path: String) : String {
        var locPath = currentLocale + "/" + path;
        if (absenceResources.exists(locPath)) locPath = DEFAULT + "/" + path;
        return assetsDir + "/" + locPath;
    }

    #if haxe3 @:noCompletion #end
    public static inline function addListener(key: String, callb: Void -> Void) : Void {
        listeners.set(key, callb);
    }

    #if haxe3 @:noCompletion #end
    public static function init() : Void {
        if (supportedLocales.length == 0)
            throw "This class is for used with 'global' locale only.";
        for (s in I18n.getAbsenceResources()) absenceResources.set(s, 1);
        trace(absenceResources);
        set_currentLocale(DEFAULT);
    }

    private static function set_currentLocale(locale: String) : String {
        if (!Lambda.has(supportedLocales, locale)) locale = DEFAULT;
        if (currentLocale == locale && map != null) return locale;
        var path = assetsDir + "/" + locale + "/strings.xml";
        map = new IntHash();
        var s = Assets.getText(path);
        if (s == null || s.length == 0)
            throw "Cannot load assets " + path + ".";
        var xml = Xml.parse(s);
        for (n in xml.firstElement().elements()) {
            var id = Std.parseInt(n.get("id"));
            var val = n.firstChild().nodeValue;
            map.set(id, val);
        }
        currentLocale = locale;
        for (callb in listeners) callb();
        return currentLocale;
    }

}
