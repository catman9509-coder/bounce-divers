extends Node

#Functions for you: load_banner(), destroy_banner(), load_interstitial(),
#load_rewarded(), load_rewarded_interstitial().

@export_group("Banner")
@export var ad_unit_id: String
@export_enum("Top", "Bottom", "Left", "Right") var position: int
@export_group("Interstitial")
@export var Ad_unit_id: String
@export_group("Rewarded")
@export var ad_unit_id_: String
@export_group("Rewarded Interstitial")
@export var Ad_unit_id_: String

signal rewarded_watched
signal rewarded_interstitial_watched

func _ready():
	MobileAds.initialize()
	
	$banner.android_unit_id = ad_unit_id
	$interstitial.android_unit_id = Ad_unit_id
	$rewarded.android_unit_id = ad_unit_id_
	$rewarded_intertitial.android_unit_id = Ad_unit_id_

func load_banner():
	$banner._on_load_banner_pressed()

func destroy_banner():
	$banner.destroy_ad_view()

func load_interstitial():
	$interstitial._on_load_pressed()

func load_rewarded():
	$rewarded._on_load_pressed()

func load_rewarded_interstitial():
	$rewarded_intertitial._on_load_pressed()
