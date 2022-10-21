package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory():Void
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedSounds.get(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
					currentTrackedSounds.remove(key);
				}
			}
		}
	}

	public static function clearStoredMemory():Void
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				Assets.cache.clearBitmapData(key);
				Assets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		@:privateAccess
		for (key in Assets.cache.getSoundKeys())
		{
			if (key != null && !currentTrackedSounds.exists(key))
			{
				var obj = Assets.cache.getSound(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
				}
			}
		}

		localTrackedAssets = [];
	}

	static public function isLocale():Bool
	{
		if (LanguageManager.save.data.language != 'en-US')
			return true;

		return false;
	}

	static var currentLevel:String;

	static public function setCurrentLevel(name:String):Void
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>):String
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (Assets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (Assets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	inline static public function getDirectory(directoryName:String, ?library:String):String
		return getPath('images/$directoryName', IMAGE, library);

	inline static public function getLibraryPath(file:String, library = "preload"):String
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
 
	inline static function getLibraryPathForce(file:String, library:String):String
		return '$library:assets/$library/$file';

	inline static function getPreloadPath(file:String):String
		return 'assets/$file';

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String):String
	{
		var defaultReturnPath = getPath(file, type, library);
		if (isLocale())
		{
			var langaugeReturnPath = getPath('locale/${LanguageManager.save.data.language}/' + file, type, library);
			if (Assets.exists(langaugeReturnPath))
				return langaugeReturnPath;
			else
				return defaultReturnPath;
		}
		else
			return defaultReturnPath;
	}

	inline static public function txt(key:String, ?library:String):String
	{
		var defaultReturnPath = getPath('data/$key.txt', TEXT, library);
		if (isLocale())
		{
			var langaugeReturnPath = getPath('locale/${LanguageManager.save.data.language}/data/$key.txt', TEXT, library);
			if (Assets.exists(langaugeReturnPath))
				return langaugeReturnPath;
			else
				return defaultReturnPath;
		}
		else
			return defaultReturnPath;
	}

	inline static public function xml(key:String, ?library:String):String
		return getPath('data/$key.xml', TEXT, library);

	inline static public function json(key:String, ?library:String):String
		return getPath('data/$key.json', TEXT, library);

	inline static public function data(key:String, ?library:String):String
		return getPath('data/$key', TEXT, library);
	
	inline static public function executable(key:String, ?library:String):String
		return getPath('executables/$key', BINARY, library);

	inline static public function chart(key:String, ?library:String):String
		return getPath('data/charts/$key.json', TEXT, library);

	inline static public function sound(key:String, ?library:String):Sound
		return returnSound(getPath('sounds/$key.$SOUND_EXT', SOUND, library));

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound
		return sound(key + FlxG.random.int(min, max), library);

	inline static public function music(key:String, ?library:String):Sound
		return returnSound(getPath('music/$key.$SOUND_EXT', MUSIC, library));

	inline static public function voices(song:String, addon:String = ""):Sound
		return returnSound('songs:assets/songs/${song.toLowerCase()}/Voices${addon}.$SOUND_EXT');

	inline static public function inst(song:String):Sound
		return returnSound('songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT');

	inline static public function externmusic(song:String):Sound
		return returnSound('songs:assets/songs/extern/${song.toLowerCase()}.$SOUND_EXT');

	inline static public function image(key:String, ?library:String):FlxGraphic
	{
		var defaultReturnPath = getPath('images/$key.png', IMAGE, library);
		if (isLocale())
		{
			var langaugeReturnPath = getPath('locale/${LanguageManager.save.data.language}/images/$key.png', IMAGE, library);
			if (Assets.exists(langaugeReturnPath))
				return returnGraphic(langaugeReturnPath);
			else
				return returnGraphic(defaultReturnPath);
		}
		else
			return returnGraphic(defaultReturnPath);
	}

	/*
		WARNING!!
		DO NOT USE splashImage, splashFile or getSplashSparrowAtlas for searching stuff in paths!!!!!
		I'm only using these for FlxSplash since the languages haven't loaded yet!
	*/
	inline static public function splashImage(key:String, ?library:String, ?ext:String = 'png'):FlxGraphic
		return returnGraphic(getPath('images/$key.$ext', IMAGE, library));

	inline static public function splashFile(file:String, type:AssetType = TEXT, ?library:String):String
		return getPath(file, type, library);

	inline static public function getSplashSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(splashImage(key, library), splashFile('images/$key.xml', library));

	inline static public function font(key:String):String
		return 'assets/fonts/$key';

	inline static public function langaugeFile():String
		return getPath('locale/languages.txt', TEXT, 'preload');

	inline static public function offsetFile(character:String):String
		return getPath('offsets/' + character + '.txt', TEXT, 'preload');

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));

	inline static public function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));

	inline static public function video(key:String, ?library:String):String
		return getPath('videos/$key.mp4', BINARY, library);

	public static function returnGraphic(path:String, ?cache:Bool = true):FlxGraphic
	{
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path), false, path, cache);
				graphic.persist = true;
				currentTrackedAssets.set(path, graphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('$path its null');
		return null;
	}

	public static function returnSound(path:String, ?cache:Bool = true):Sound
	{
		if (Assets.exists(path, SOUND))
		{
			if (!currentTrackedSounds.exists(path))
				currentTrackedSounds.set(path, Assets.getSound(path, cache));

			localTrackedAssets.push(path);
			return currentTrackedSounds.get(path);
		}

		trace('$path its null');
		return null;
	}
}