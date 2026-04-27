extends CharacterBody3D

#Variables
@export var SPEED = 1.5
@onready var camera: Camera3D = $Head/Camera3D
@export var sensibilidade: float = 100.0
var initial_camera_pos: Vector3
var sensi: float
var mouseLock = true
var acceleration: float = 6.0
var friction: float = 10.0
var bob_freq = 4.5
var bob_amp = 0.08
var t_bob = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_camera_pos = camera.transform.origin

func _physics_process(delta: float) -> void:
	movement(delta)
	menu()

func _input(event) -> void:
	mouseMove(event)

#Tudo relacionado ao movimento do player
func movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * SPEED, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)
	
	# === APLICANDO O HEAD BOBBING ===
	var velocity_clamped = Vector3(velocity.x, 0, velocity.z).length()
	
	# O alvo padrão da câmera é a posição inicial (parada)
	var target_camera_pos = initial_camera_pos 

	# Se estiver andando, o alvo passa a ser o movimento da onda
	if is_on_floor() and velocity_clamped > 0.5:
		t_bob += delta * velocity_clamped 
		target_camera_pos = initial_camera_pos + _headbob(t_bob) 

	# Fazemos o lerp O TEMPO TODO. A câmera sempre vai deslizar para o 'target'
	camera.transform.origin = camera.transform.origin.lerp(target_camera_pos, delta * 10.0)
	
	if Input.is_action_pressed("sprint"):
		SPEED = 3.0
		camera.fov = lerp(camera.fov, 80.0, 10.0 * delta)
	else:
		SPEED = 1.5
		camera.fov = lerp(camera.fov, 75.0, 10.0 * delta)
	move_and_slide()

#Tudo que usa o movimento do mouse
func mouseMove(event):
	if event is InputEventMouseMotion:
		var movimentoX = event.relative.x
		var movimentoY = event.relative.y
		
		sensi = sensibilidade / 99900.0
		
		#print("Movimento detectado: ", movimentoX, " ", movimentoY)
		camera.rotation.x -= movimentoY * sensi
		rotation.y -= movimentoX * sensi
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

#função para printar coisas no console (apenas para testes)
func printLog():
	pass

func menu():
	if Input.is_action_just_pressed("ui_cancel") and mouseLock == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouseLock = false
	elif Input.is_action_just_pressed("ui_cancel") and mouseLock == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouseLock = true

# === FUNÇÃO DO MOVIMENTO DE ONDA ===
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	# Eixo Y (Sobe e desce): Cria o impacto dos passos no chão
	pos.y = sin(time * bob_freq) * bob_amp
	
	# Eixo X (Esquerda e direita): Imita o peso trocando de perna
	pos.x = cos(time * bob_freq / 2.0) * bob_amp 
	
	return pos
