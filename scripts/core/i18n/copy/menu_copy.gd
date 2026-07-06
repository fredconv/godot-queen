class_name MenuCopy
extends RefCounted
## Textes formatés du menu principal (`translations/menu.csv`).


const PIXABAY_USER_URL: String = (
	"https://pixabay.com/users/alexis_gaming_cam-50011695/"
	+ "?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=346103"
)
const PIXABAY_SITE_URL: String = (
	"https://pixabay.com/?utm_source=link-attribution&utm_medium=referral"
	+ "&utm_campaign=music&utm_content=346103"
)


static func credits_sfx_attribution_bbcode() -> String:
	var user_link: String = "[url=%s]ALEXIS_GAMING_CAM[/url]" % PIXABAY_USER_URL
	var site_link: String = "[url=%s]Pixabay[/url]" % PIXABAY_SITE_URL
	return TranslationServer.translate(MenuKeys.CREDITS_SFX_ATTRIBUTION) % [user_link, site_link]
