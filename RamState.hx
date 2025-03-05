package states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;

class RamState extends MusicBeatState
{
	var warnText:FlxText;

	override function create()
		{
			super.create();
	
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			add(bg);
	
			var ramGB:Float = Math.round(getSystemRAM() * 100) / 100; // Round to 2 decimal places, it means that it will round to 2 decimal places. For example, 7.93126468952.. GB will be 7.93 GB.
	
			warnText = new FlxText(0, 0, FlxG.width, 
				"Heya!!\n" +
				"<YourModName> needs at least X GB of RAM to run nicely.\n\n" + // X should be the amount of RAM!! For example, if you want to have 6 GB of RAM, you should replace X with 6.
				"System Detected RAM: " + ramGB + " GB\n\n" +
				"You can press ESC to ignore and continue anyway.\n" +
				"You've been warned!",
				32);
			warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
			warnText.screenCenter(Y);
			add(warnText);
	
			if (ramGB < X) { // X should be the amount of RAM!! For example, if you want to have 6 GB of RAM, you should replace X with 6.
				trace('Warning: System has less than X GB of RAM. Detected RAM: ' + ramGB + ' GB');
			} else {
				trace('System has sufficient RAM: ' + ramGB + ' GB');
				MusicBeatState.switchState(new TitleState());
			}
		}
	
		override function update(elapsed:Float)
		{
			super.update(elapsed);
	
			if (FlxG.keys.justPressed.ESCAPE) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(warnText, {x: 1200}, 1, { ease: FlxEase.expoInOut, onComplete: cast(function() {
					MusicBeatState.switchState(new TitleState());
				})});
			}
		}
		
		function getSystemRAM():Float {
			#if windows
			var process = new Process("wmic", ["OS", "get", "TotalVisibleMemorySize"]);
			var output = process.stdout.readAll().toString();
			process.close();
	
			var lines = output.split("\n");
			for (line in lines) {
				var trimmed = StringTools.trim(line);
				if (~/^\d+$/.match(trimmed)) {
					return Std.parseInt(trimmed) / (1024 * 1024); 
				}
			}
			#elseif linux
			var process = new Process("grep", ["MemTotal", "/proc/meminfo"]);
			var output = process.stdout.readAll().toString();
			process.close();
	
			var parts = output.split(":");
			if (parts.length > 1) {
				var kbRam = Std.parseInt(parts[1].replace("kB", "").trim());
				return kbRam / (1024 * 1024);
			}
			#end
	
			return 0;
		}
	}
	