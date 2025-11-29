extends Control

## Phone Call UI Manager
## Manages the mute button and subtitle display during phone calls

signal phone_muted
signal phone_unmuted

# References
@onready var mute_button: Button = $MuteButton if has_node("MuteButton") else null
@onready var subtitle_label: Label = $SubtitlePanel/MarginContainer/SubtitleLabel if has_node("SubtitlePanel/MarginContainer/SubtitleLabel") else null
@onready var subtitle_panel: PanelContainer = $SubtitlePanel if has_node("SubtitlePanel") else null

# Subtitle data for each night
var subtitle_data: Array = []
var current_subtitle_index: int = 0
var subtitle_timer: float = 0.0
var is_phone_playing: bool = false
var is_muted: bool = false

# Audio manager reference
var audio_manager: Node = null

func _ready() -> void:
	# Hide UI initially
	visible = false
	
	# Debug: Check if nodes exist
	print("[PhoneCallUI] _ready() called")
	print("[PhoneCallUI] mute_button exists: ", mute_button != null)
	print("[PhoneCallUI] subtitle_label exists: ", subtitle_label != null)
	print("[PhoneCallUI] subtitle_panel exists: ", subtitle_panel != null)
	
	# Setup button
	if mute_button:
		mute_button.pressed.connect(_on_mute_button_pressed)
		_update_mute_button_text()
		print("[PhoneCallUI] MuteButton position: ", mute_button.position)
		print("[PhoneCallUI] MuteButton size: ", mute_button.size)
	else:
		print("[PhoneCallUI] ERROR: MuteButton not found!")
	
	# Hide subtitles initially
	if subtitle_panel:
		subtitle_panel.visible = GlobalData.subtitles_enabled
	
	# Find audio manager - it's a sibling node in the nights scene
	audio_manager = get_parent().get_node_or_null("AudioManager")
	
	# Connect to audio manager signals
	if audio_manager:
		audio_manager.phone_call_started.connect(_on_phone_call_started)
		audio_manager.phone_call_ended.connect(_on_phone_call_ended)
		print("[PhoneCallUI] Connected to AudioManager")
	else:
		print("[PhoneCallUI] Warning: AudioManager not found!")

func _process(delta: float) -> void:
	if is_phone_playing and GlobalData.subtitles_enabled:
		_update_subtitles(delta)

func _on_phone_call_started() -> void:
	"""Called when phone call starts"""
	is_phone_playing = true
	visible = true
	is_muted = false
	
	# Debug visibility
	print("[PhoneCallUI] Phone call started - showing UI")
	print("[PhoneCallUI] PhoneCallUI visible: ", visible)
	if mute_button:
		print("[PhoneCallUI] MuteButton visible: ", mute_button.visible)
		print("[PhoneCallUI] MuteButton global_position: ", mute_button.global_position)
		mute_button.visible = true  # Force visible
	
	# Load subtitle data for current night
	_load_subtitle_data(GlobalData.current_night)
	current_subtitle_index = 0
	subtitle_timer = 0.0
	
	# Show/hide subtitle panel based on settings
	if subtitle_panel:
		subtitle_panel.visible = GlobalData.subtitles_enabled
	
	# Clear subtitle label
	if subtitle_label:
		subtitle_label.text = ""
	
	_update_mute_button_text()
	
	print("[PhoneCallUI] Phone call UI shown. Subtitles enabled: ", GlobalData.subtitles_enabled)
	print("[PhoneCallUI] Loaded ", subtitle_data.size(), " subtitle entries")

func _on_phone_call_ended() -> void:
	"""Called when phone call ends"""
	is_phone_playing = false
	visible = false
	
	# Clear subtitles
	if subtitle_label:
		subtitle_label.text = ""

func _on_mute_button_pressed() -> void:
	"""Toggle mute state"""
	is_muted = !is_muted
	
	if audio_manager:
		if is_muted:
			audio_manager.stop_phone_call()
			emit_signal("phone_muted")
		else:
			# Can't unmute once stopped in FNAF
			pass
	
	_update_mute_button_text()

func _update_mute_button_text() -> void:
	"""Update button text based on mute state"""
	if mute_button:
		if is_muted:
			mute_button.text = "Phone Muted"
			mute_button.disabled = true  # Can't unmute in FNAF
		else:
			mute_button.text = "Mute Call"

func _update_subtitles(delta: float) -> void:
	"""Update subtitle display"""
	if not subtitle_label:
		print("[PhoneCallUI] ERROR: subtitle_label is null!")
		return
	
	if not GlobalData.subtitles_enabled:
		return
	
	if subtitle_data.is_empty():
		print("[PhoneCallUI] WARNING: subtitle_data is empty!")
		return
	
	subtitle_timer += delta
	
	# Check if we need to show next subtitle
	if current_subtitle_index < subtitle_data.size():
		var subtitle_entry = subtitle_data[current_subtitle_index]
		if subtitle_timer >= subtitle_entry["time"]:
			var text = subtitle_entry["text"]
			subtitle_label.text = text
			current_subtitle_index += 1
			print("[PhoneCallUI] Showing subtitle at ", subtitle_timer, "s: ", text)

func _load_subtitle_data(night: int) -> void:
	"""Load subtitle timing and text for the given night"""
	subtitle_data = []
	
	match night:
		1:
			subtitle_data = _get_night_1_subtitles()
		2:
			subtitle_data = _get_night_2_subtitles()
		3:
			subtitle_data = _get_night_3_subtitles()
		4:
			subtitle_data = _get_night_4_subtitles()
		5:
			subtitle_data = _get_night_5_subtitles()
		6:
			subtitle_data = _get_night_6_subtitles()
		7:
			subtitle_data = _get_night_7_subtitles()

# ===== SUBTITLE DATA FOR EACH NIGHT =====
# Format: [{"time": seconds, "text": "subtitle text"}]
# TODO: Replace with actual subtitle timing and text

func _get_night_1_subtitles() -> Array:
	return [
		{"time": 0.0, "text": "*Suara Batuk*"},
		{"time": 2.0, "text": "Tes.. Tes..."},
		{"time": 4.0, "text": "Halo bos, masuk gak suaraku?"},
		{"time": 8.0, "text": "Sip, Taruna malam pertama nih."},
		{"time": 11.0, "text": "Oke, jadi gini, tugasmu tuh simple..."},
		{"time": 15.0, "text": "Teorinya sih simple."},
		{"time": 18.0, "text": "Kamu cuma mantau CCTV,"},
		{"time": 20.0, "text": "terus pastiin nggak ada yang aneh-aneh"},
		{"time": 22.0, "text": "dan jaga ruangan tetep aman sampai jam 6 pagi."},
		{"time": 25.0, "text": "Santai aja, nggak harus keliling kok,"},
		{"time": 28.0, "text": "malahan jangan keluar ruangan, ngerti?"},
		{"time": 32.0, "text": "Nah, kanan kirimu kan ada tombol pintu sama lampu."},
		{"time": 37.0, "text": "Itu tuh, jangan asal dipencet,"},
		{"time": 39.0, "text": "Listrik gedung ni kadang aneh kek punya pikiran sendiri,"},
		{"time": 43.0, "text": "dikit-dikit suka ngedrop, jadi pakai seperlunya, inget?"},
		{"time": 46.0, "text": "SE-PER-LU-NYA."},
		{"time": 51.0, "text": "Dan... CCTV."},
		{"time": 53.0, "text": "Pakai tablet mu biar bisa ganti kamera."},
		{"time": 56.0, "text": "Kalau ada suara ketok-ketok,"},
		{"time": 58.0, "text": "suara mesin, atau kaya ada orang lari, jangan langsung panik."},
		{"time": 63.0, "text": "*Mengela nafas*"},
		{"time": 65.0, "text": "Itu tuh seringnya cuma pintu kelas yang kegeser angin,"},
		{"time": 70.0, "text": "ya kadang speaker sekolah suka ngawur."},
		{"time": 74.0, "text": "Tapi jangan khawatir, kalau kamu lihat sesuatu yang nggak harus gerak,"},
		{"time": 79.0, "text": "pura-pura nggak lihat juga nggak apa-apa."},
		{"time": 82.0, "text": "Kadang kamera ngerekam hal-hal yang lebih baik kita gausah paham, ngerti kan?"},
		{"time": 88.0, "text": "Intinya, mode hemat listrik itu penting."},
		{"time": 91.0, "text": "Nek pintune mok tutup terus podo ae karo tekor pulsa."},
		{"time": 95.0, "text": "Awakmu gak pengen toh listrik mati tengah malam?,"},
		{"time": 98.0, "text": "Orang-orang sana sih selalu bilang laporannya aman,"},
		{"time": 103.0, "text": "lucu ya, kalau memang aman, kenapa harus panggil satpam baru coba,"},
		{"time": 108.0, "text": "kenapa nggak pake satpam lama seperti saya? malah saya disuruh mantau kamu."},
		{"time": 115.0, "text": "Tapi yaudahlah saya cuma ikut sama atasan,"},
		{"time": 119.0, "text": "mana berani saya ngelawan,"},
		{"time": 121.0, "text": "takut nanti gajinya dipotong, hehe."},
		{"time": 125.0, "text": "Yoweslah, iku sek ae. Naik pangkat dulu kamu jadi penjaga malam."},
		{"time": 130.0, "text": "Santai aja, ngga usah aneh-aneh,"},
		{"time": 133.0, "text": "besok aku telfon lagi,"},
		{"time": 135.0, "text": "semoga aman sampai nanti pagi, semangat satpam taruna."},
	]

func _get_night_2_subtitles() -> Array:
	return [
		{"time": 0.0, "text": "Halo, woe balik lagi kau."},
		{"time": 4.0, "text": "Niat banget, respect-respect."},
		{"time": 8.0, "text": "Gimana kemaren? aman nggak? aman lah ya."},
		{"time": 13.0, "text": "Uhh, update dikit nih,"},
		{"time": 15.0, "text": "ada laporan tadi dari lab TKJ,"},
		{"time": 18.0, "text": "katanya beberapa robot tuh kaya gerak sendiri,"},
		{"time": 22.0, "text": "katanya sih, sensornya error, tadi juga sempet dicoba buat dibenahin"},
		{"time": 29.0, "text": "tapi yang lapor mukanya pucet semua, jadi... ya terserah kamu mau percaya atau nggak."},
		{"time": 36.0, "text": "Kalau kamu lihat posisi robot berubah dari CCTV, itu tuh normal, untuk sekarang lah ya."},
		{"time": 44.0, "text": "Dan... kalau ada yang mulai mendekat ke ruanganmu,"},
		{"time": 47.0, "text": "tinggal tutup pintu sebentar biar mereka mundur."},
		{"time": 50.0, "text": "Mereka kayanya sensitif sama ruang tertutup."},
		{"time": 53.0, "text": "Kamu harusnya aman kok, asal nggak ngelamunin pintu kebuka."},
		{"time": 58.0, "text": "Semangat ya, jangan lupa simpen tenaga buat besok, lanjut lanjut."},
		
	]

func _get_night_3_subtitles() -> Array:
	return [
		{"time": 0.0, "text": "Halo wok, malam ketiga nih."},
		{"time": 3.0, "text": "Dengerin nih, ada berita baru,"},
		{"time": 7.0, "text": "anak-anak TKR refine robotnya buat lomba,"},
		{"time": 11.0, "text": "tapi nggak tau kenapa setelah itu robotnya makin aktif,"},
		{"time": 14.0, "text": "kaya nyari sesuatu atau..."},
		{"time": 18.0, "text": "seseorang?"},
		{"time": 21.0, "text": "Kalau robot-robot nungguin kamu di koridor, ya mungkin mereka ngefens."},
		{"time": 26.0, "text": "Kalau kamu misal denger suara gesekan besi atau langkah kaki berat kayak,"},
		{"time": 30.0, "text": "klang-kleng-klang-kleng"},
		{"time": 32.0, "text": "Itu robot TKR baru diceperin,"},
		{"time": 34.0, "text": "eh"},
		{"time": 36.0, "text": "salah, 'direfine'."},
		{"time": 39.0, "text": "Dia tuh sering jalan-jalan sendiri, tetep siaga terus, sekarang kamera bisa nge-glitch kadang."},
		{"time": 46.0, "text": "Misal nih, misal..."},
		{"time": 48.0, "text": "CCTV nya nge-freeze, atau gambarnya patah-patah, coba deh buka kamera 6,"},
		{"time": 53.0, "text": "biasanya aku fix-in dari situ."},
		{"time": 56.0, "text": "oke iku wae sek malam iki,"},
		{"time": 59.0, "text": "Misal nih, misal..."},
		{"time": 61.0, "text": "CCTV nya nge-freeze, atau gambarnya patah-patah, coba deh buka kamera 6,"},
		{"time": 66.0, "text": "biasanya aku fix-in dari situ."},
		{"time": 69.0, "text": "oke iku wae sek malam iki, sesok maneh, ojok lali kopine."},
	]

func _get_night_4_subtitles() -> Array:
	return [
		{"time": 0.0, "text": "Info..."},
		{"time": 3.0, "text": "Awakmu iseh strong ya, jos jis bolo...!"},
		{"time": 7.0, "text": "Onok berita kurang enak, anak-anak TKJ upgrade power system hari ini."},
		{"time": 13.0, "text": "Bagus sih buat lomba, tapi... jelek buat kamu."},
		{"time": 18.0, "text": "Kadang sistem mereka nyedot tenaga listrik lebih..."},
		{"time": 22.0, "text": "Kaya orang nggak minum air seminggu."},
		{"time": 25.0, "text": "Kalo tiba-tiba power kamu boros tanpa alasan, coba deh buka kamera 7 di lab TKJ."},
		{"time": 32.0, "text": "Ada tombol fix power, pencet sekali terus tutup."},
		{"time": 36.0, "text": "Fokus terus, besok malam kamu terakhir shift resmi loh..."},
		{"time": 40.0, "text": "*Bergembira*"},
	]

func _get_night_5_subtitles() -> Array:
	return [
		{"time": 0.0, "text": "Halo! Bro malam kelima..!"},
		{"time": 4.0, "text": "tinggal selangkah lagi nih, cuma..."},
		{"time": 7.0, "text": "ya... ada satu hal penting..."},
		{"time": 11.0, "text": "Robot prototype besar yang di depan bengkel, tahu kan? yang TPM/LAS."},
		{"time": 17.0, "text": "Katanya anak-anak si gerak sendiri tadi siang..."},
		{"time": 23.0, "text": "Sama... robot itu belum punya sensor pengenal manusia,"},
		{"time": 28.0, "text": "jadi kalau misal dia nyasar keruang penjagaan,"},
		{"time": 32.0, "text": "dia anggap apapun yang dia lihat, sebagai target."},
		{"time": 37.0, "text": "Kalau kamu dengar suara berat kaya monster mesin kelaperan itu dia."},
		{"time": 42.0, "text": "Jangan biarin dia lihat kamu dari kamera depan,"},
		{"time": 45.0, "text": "tutup pintu dulu, baru cek kameranya dan dia sensitif sama kamera."},
		{"time": 52.0, "text": "Kalau kamu pantau dia, dia bakal diem atau ngga gitu nge-freeze sebentar."},
		{"time": 56.0, "text": "Pakai itu kesempatan buat mikir langkah selanjutnya."},
		{"time": 60.0, "text": "Good luck brok."},
	]

func _get_night_6_subtitles() -> Array:
	return [
		{"time": 0.0, "text": "HALOO, HALOO...!"},
		{"time": 2.0, "text": "LOH, HEH awakmu lapo mrono maneh??"},
		{"time": 6.0, "text": "LOH, LOM dekne lapo mrono maneh??"},
		{"time": 9.0, "text": "LOH, GAK yo wes mok kandani leh yon???"},
		{"time": 12.0, "text": "UWES LOM, SUMPAH!!"},
		{"time": 15.0, "text": "WOE! kamu nggak baca kontraknya ya??"},
		{"time": 18.0, "text": "kalau shift malam tuh cuman 5 malam tok..!"},
		{"time": 21.0, "text": "Nggak ada lemburan! Nggak ada bonus! Nggak ada piagam..! "},
		{"time": 24.0, "text": "Kek.. ngapain coba balik lagi??"},
		{"time": 26.0, "text": "Hey, kamu nggak denger beritanya toh? hari ini itu sekolah diliburkan karena ada kerusuhan"},
		{"time": 32.0, "text": "dengan robot-robot itu..!"},
		{"time": 34.0, "text": "Wes pokoknya malam ini bukan malam biasa..."},
		{"time": 37.0, "text": "Bukan waktunya buat main-main..!"},
		{"time": 40.0, "text": "Robot-robot keluyuran sampai kelas, lorong, bahkan banyak yang naik turun tangga..!"},
		{"time": 44.0, "text": "Ada beberapa insiden, sensor mereka lose control dan banyak yang error..."},
		{"time": 49.0, "text": "Tadi ada anak yang pulang terlambat, katanya si sempet dikejar salah satu robot itu..!"},
		{"time": 56.0, "text": "Dengerin aku. Jangan keluar ruangan, jangan coba-coba buat kabur, jangan tinggalin pos..."},
		{"time": 63.0, "text": "Kalau kamu jalan diluar, takutnya ada sesuatu yang duluan nemuin kamu..."},
		{"time": 67.0, "text": "Ini bener-bener yang terakhir..."},
		{"time": 70.0, "text": "Bertahan sampai pagi, dan kamu bisa bebas dari tempat yang nggak beres ini..."},
		{"time": 74.0, "text": "SURVIVE!"},
	]

func _get_night_7_subtitles() -> Array:
	return [
		{"time": 0.0, "text": "*No phone call on Custom Night*"},
	]
