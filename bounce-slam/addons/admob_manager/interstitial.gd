extends Node

var _interstitial_ad: InterstitialAd
var _full_screen_content_callback := FullScreenContentCallback.new()

var android_unit_id := "ca-app-pub-3940256099942544/1033173712"
var ios_unit_id := "ca-app-pub-3940256099942544/4411468910"

func _ready() -> void:
	_full_screen_content_callback.on_ad_clicked = func() -> void:
		print("on_ad_clicked")
	_full_screen_content_callback.on_ad_impression = func() -> void:
		print("on_ad_impression")
	_full_screen_content_callback.on_ad_showed_full_screen_content = func() -> void:
		print("on_ad_showed_full_screen_content")
	_full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(ad_error: AdError) -> void:
		print("on_ad_failed_to_show_full_screen_content")
	_full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("on_ad_dismissed_full_screen_content")
		if _interstitial_ad:
			_interstitial_ad.destroy()
			_interstitial_ad = null


func _on_load_pressed() -> void:
	if _interstitial_ad:
		_interstitial_ad.destroy()
		_interstitial_ad = null

	var unit_id := ""
	if OS.get_name() == "Android":
		unit_id = android_unit_id
	elif OS.get_name() == "iOS":
		unit_id = ios_unit_id

	var load_callback := InterstitialAdLoadCallback.new()

	load_callback.on_ad_failed_to_load = func(error: LoadAdError) -> void:
		print(error.message)

	load_callback.on_ad_loaded = func(ad: InterstitialAd) -> void:
		print("Interstitial loaded")

		_interstitial_ad = ad
		_interstitial_ad.full_screen_content_callback = _full_screen_content_callback
		_interstitial_ad.show() # Show automatically after loading

	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), load_callback)
