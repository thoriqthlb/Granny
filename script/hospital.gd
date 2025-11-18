extends Node3D

# --- REFERENSI ALAT (LABEL & TIMER) ---
@onready var timer_1 = $Timer_1
@onready var timer_2 = $Timer_2
@onready var timer_3 = $Timer_3
@onready var timer_4 = $Timer_4

@onready var teks_1 = $Teks_Pintu_1
@onready var teks_2 = $Teks_Pintu_2
@onready var teks_3 = $Teks_Pintu_3
@onready var teks_4 = $Teks_Pintu_4

# --- INGATAN (PASIEN DI MANA?) ---
var pasien_di_pintu_1 = null
var pasien_di_pintu_2 = null
var pasien_di_pintu_3 = null
var pasien_di_pintu_4 = null

func _ready():
	# Set semua tulisan awal jadi hijau
	teks_1.text = "KOSONG"; teks_1.modulate = Color.GREEN
	teks_2.text = "KOSONG"; teks_2.modulate = Color.GREEN
	teks_3.text = "KOSONG"; teks_3.modulate = Color.GREEN
	teks_4.text = "KOSONG"; teks_4.modulate = Color.GREEN

func _process(delta):
	# Update angka hitung mundur JIKA timer sedang jalan
	if not timer_1.is_stopped(): teks_1.text = str(ceil(timer_1.time_left))
	if not timer_2.is_stopped(): teks_2.text = str(ceil(timer_2.time_left))
	if not timer_3.is_stopped(): teks_3.text = str(ceil(timer_3.time_left))
	if not timer_4.is_stopped(): teks_4.text = str(ceil(timer_4.time_left))

# --- LOGIKA INPUT (TOMBOL F) ---
func _input(event):
	if event.is_action_pressed("send"):
		proses_interaksi(1, pasien_di_pintu_1, timer_1, teks_1)
		proses_interaksi(2, pasien_di_pintu_2, timer_2, teks_2)
		proses_interaksi(3, pasien_di_pintu_3, timer_3, teks_3)
		proses_interaksi(4, pasien_di_pintu_4, timer_4, teks_4)

# Fungsi khusus biar kita ga nulis kode berulang-ulang
func proses_interaksi(no_pintu, pasien, timer, teks):
	if pasien != null and timer.is_stopped():
		pasien.queue_free() # Hapus pasien
		
		# Reset ingatan variabel global (PENTING)
		if no_pintu == 1: pasien_di_pintu_1 = null
		elif no_pintu == 2: pasien_di_pintu_2 = null
		elif no_pintu == 3: pasien_di_pintu_3 = null
		elif no_pintu == 4: pasien_di_pintu_4 = null
		
		timer.start()
		teks.modulate = Color.RED
		print("Pasien masuk Pintu " + str(no_pintu))

# --- LOGIKA SENSOR MASUK ---
func _on_sensor_1_body_entered(body): if body.is_in_group("pasien"): pasien_di_pintu_1 = body
func _on_sensor_2_body_entered(body): if body.is_in_group("pasien"): pasien_di_pintu_2 = body
func _on_sensor_3_body_entered(body): if body.is_in_group("pasien"): pasien_di_pintu_3 = body
func _on_sensor_4_body_entered(body): if body.is_in_group("pasien"): pasien_di_pintu_4 = body

# --- LOGIKA SENSOR KELUAR ---
func _on_sensor_1_body_exited(body): if body == pasien_di_pintu_1: pasien_di_pintu_1 = null
func _on_sensor_2_body_exited(body): if body == pasien_di_pintu_2: pasien_di_pintu_2 = null
func _on_sensor_3_body_exited(body): if body == pasien_di_pintu_3: pasien_di_pintu_3 = null
func _on_sensor_4_body_exited(body): if body == pasien_di_pintu_4: pasien_di_pintu_4 = null

# --- LOGIKA TIMER HABIS ---
func _on_timer_1_timeout(): teks_1.text = "KOSONG"; teks_1.modulate = Color.GREEN
func _on_timer_2_timeout(): teks_2.text = "KOSONG"; teks_2.modulate = Color.GREEN
func _on_timer_3_timeout(): teks_3.text = "KOSONG"; teks_3.modulate = Color.GREEN
func _on_timer_4_timeout(): teks_4.text = "KOSONG"; teks_4.modulate = Color.GREEN
