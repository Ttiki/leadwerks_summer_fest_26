#pragma once
#include "Leadwerks.h"
#include "SrcPlayer.h"

using namespace Leadwerks;

void SrcPlayer::Start()
{
	auto entity = GetEntity();

	// Set the physics mode to PHYSICS_PLAYER, this will enable the character controller.
	entity->SetPhysicsMode(PHYSICS_PLAYER);

	// If the mass happens to be 0, force set the mass to a default value.
	if (entity->GetMass() == 0.0f) entity->SetMass(78);

	// Set the collision type to  COLLISION_PLAYER
	entity->SetCollisionType(COLLISION_PLAYER);

	// Disable shadows
	entity->SetShadows(false);

	// Never render this entity!
	entity->SetRenderLayers(0);

	entity->SetNavObstacle(false);

	entity->RecordCollisions(true);

	flashlightrotation = camera->GetQuaternion(true);

	// Listen for window events we want to use
	Listen(EVENT_KEYDOWN, NULL);
	Listen(EVENT_KEYUP, NULL);
	Listen(EVENT_WORLDPAUSE, entity->GetWorld());

	for (int n = 0; n < sound_hit.size(); ++n)
	{
		sound_hit[n] = LoadSound("Sound/Impact/bodypunch" + String(n + 1) + ".wav");
	}
	sound_jump = LoadSound("Sound/Footsteps/Concrete/jump.wav");
	for (int n = 0; n < sound_step.size(); ++n)
	{
		sound_step[n] = LoadSound("Sound/Footsteps/Concrete/step" + String(n + 1) + ".wav");
	}

	const float scale = 0.25f;
	std::vector<Vec3> points;

	// Add corners for a cube
	points.push_back(Vec3(0.5, 0.5f, 0.5) * scale);
	points.push_back(Vec3(-0.5, 0.5f, 0.5) * scale);
	points.push_back(Vec3(0.5, -0.5f, 0.5) * scale);
	points.push_back(Vec3(-0.5, -0.5f, 0.5) * scale);
	points.push_back(Vec3(0.5, 0.5f, -0.5) * scale);
	points.push_back(Vec3(-0.5, 0.5f, -0.5) * scale);
	points.push_back(Vec3(0.5, -0.5f, -0.5) * scale);
	points.push_back(Vec3(-0.5, -0.5f, -0.5) * scale);

	// Add some points sticking out so the shape rolls a little bit
	points.push_back(Vec3(0.0f, 0.0f, -0.667f) * scale);
	points.push_back(Vec3(0.0f, 0.0f, 0.667f) * scale);
	points.push_back(Vec3(0.0f, -0.667f, 0.0f) * scale);
	points.push_back(Vec3(0.0f, 0.667f, 0.0f) * scale);
	points.push_back(Vec3(-0.667f, 0.0f, 0.0f) * scale);
	points.push_back(Vec3(0.667f, 0.0f, 0.0f) * scale);

	deadbodycollider = CreateConvexHullCollider(points);

	Player::Start();
}


bool SrcPlayer::ProcessEvent(const Event& e)
{
	if (not GetEnabled()) return true;
	if (GetHealth() <= 0) return true;

	auto entity = GetEntity();
	auto world = entity->GetWorld();
	if (world->GetPaused()) return true;

	switch (e.id)
	{
	case EVENT_WORLDPAUSE:
		freelookstarted = false;
		break;
	case EVENT_KEYDOWN:
		if (e.data == KEY_SPACE)
		{
			jumpkey = true;
		}
		if (e.data == KEY_CONTROL)
		{
			crouchkey = true;
		}
		if (e.data == KEY_E)
		{
			if (world)
			{
				auto pos = entity->GetPosition(true);
				Aabb bounds = Aabb(pos - 2.0f, pos + 2.0f);
				auto entities = world->GetEntitiesInArea(bounds.min, bounds.max);
				for (auto e : entities)
				{
					if (e == entity) continue;
					for (auto c : e->components)
					{
						auto base = c->As<BaseComponent>();
						if (base and base->GetEnabled()) base->Use(entity);
					}
				}
			}
		}
		break;
	case EVENT_KEYUP:
		if (e.data == KEY_SPACE)
		{
			jumpkey = false;
		}
		if (e.data == KEY_CONTROL)
		{
			crouchkey = false;
		}
		break;
	}
	return true;
}

static bool UnCrouchFilter(std::shared_ptr<Entity> entity, std::shared_ptr<Object> extra)
{
	if (entity == extra->As<Entity>())
		return false;

	if (entity->GetCollider() == NULL || entity->GetCollisionType() == COLLISION_NONE
		|| entity->GetCollisionType() == COLLISION_TRIGGER) {
		return false;
	}

	return true;
}

void SrcPlayer::Update()
{
	if (not GetEnabled()) return;
	if (GetHealth() <= 0) return;

	UpdateMovement();
}
void SrcPlayer::UpdateFootsteps()
{
	auto entity = GetEntity();
	auto world = entity->GetWorld();
	if (not world) return;
	if (not entity->GetAirborne() and movement.Length() > 0.0f)
	{
		auto now = world->GetTime();
		float speed = entity->GetVelocity().xz().Length();
		int footsteptime = Clamp(500.0f * this->movespeed / speed, 250.0f, 1000.0f);
		if (now - lastfootsteptime > footsteptime)
		{
			lastfootsteptime = now;
			int index = Round(Random(0, sound_step.size() - 1));
			if (sound_step[index]) sound_step[index]->Play();
		}
	}
}

void SrcPlayer::Collide(shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed)
{
    
}


void SrcPlayer::UpdateMovement()
{
	movement = 0.0f;

	float jump = 0;

	auto entity = GetEntity();

	auto world = entity->GetWorld();

	auto window = ActiveWindow();
	if (window)
	{
		running = entity->GetCrouched() == false and window->KeyDown(KEY_SHIFT);
		walking = entity->GetCrouched() == false and window->KeyDown(KEY_ALT);

		auto cx = Round((float)window->GetFramebuffer()->GetSize().x / 2);
		auto cy = Round((float)window->GetFramebuffer()->GetSize().y / 2);
		auto mpos = window->GetMousePosition();
		window->SetMousePosition(cx, cy);
		auto centerpos = window->GetMousePosition();

		if (freelookstarted)
		{
			float looksmoothing = mousesmoothing; //0.5f;
			float lookspeed = mouselookspeed / 10.0f;

			float dx = mpos.x - centerpos.x;
			float dy = mpos.y - centerpos.y;

			if (looksmoothing > 0.0f)
			{
				mousedelta.x = CurveValue(dx, mousedelta.x, 1.0f + looksmoothing);
				mousedelta.y = CurveValue(dy, mousedelta.y, 1.0f + looksmoothing);
			}
			else
			{
				mousedelta.x = dx;
				mousedelta.y = dy;
			}

			freelookrotation.x = Clamp(freelookrotation.x + mousedelta.y * lookspeed, -90.0f, 90.0f);
			freelookrotation.y += mousedelta.x * lookspeed;
			camera->SetRotation(freelookrotation, true);
			freelookmousepos = Vec3(mpos.x, mpos.y);
		}
		else
		{
			freelookstarted = true;
			freelookrotation = camera->GetRotation(true);
			freelookmousepos = Vec3(window->GetMousePosition().x, window->GetMousePosition().y);
			window->SetCursor(CURSOR_NONE);
		}

		// Camera shake when hit
		float speed = 0.1f;
		float diff = Vec4(camerashakerotation.x, camerashakerotation.y, camerashakerotation.z, camerashakerotation.w).Length();
		camerashakerotation = camerashakerotation.Slerp(Quat(0, 0, 0, 1), Min(1.0f, speed / diff));
		smoothedcamerashakerotation = smoothedcamerashakerotation.Slerp(camerashakerotation, 0.5f);
		camera->Turn(smoothedcamerashakerotation.ToEuler(), false);

		// We use the base class' enabled bool to lock the movement.
		if (GetEnabled())
		{
			float speed = movespeed;
			if (entity->GetAirborne())
			{
				speed *= 0.25f;
			}
			
			if (running)
			{
				speed *= 2.0f;
			}
			if (walking)
			{
				speed *= 0.5f;
			}
			else if (crouchkey)
			{
				speed *= 0.5f;
			}

			if (jumpkey)
			{
				jump = jumpforce;
				if (sound_jump) sound_jump->Play();
			}
			
			if (window->KeyDown(KEY_D)) movement.x += speed;
			if (window->KeyDown(KEY_A)) movement.x -= speed;
			if (window->KeyDown(KEY_W)) movement.z += speed;
			if (window->KeyDown(KEY_S)) movement.z -= speed;
			if (movement.x != 0.0f and movement.z != 0.0f) movement *= 0.707f;
			if (jump != 0.0f)
			{
				movement.x *= jumplunge;
				if (movement.z > 0.0f) movement.z *= jumplunge;
			}
		}
	}

	entity->SetInput(camera->rotation.y, movement.z, movement.x, jump, crouchkey);

	if (agent) agent->SetPosition(entity->GetPosition(true));

	static float eye = eyeheight;
	if (entity->GetCrouched())
	{
		if (not entity->GetAirborne()) eye = croucheyeheight;
	}
	else
	{
		eye = eyeheight;
	}

	float y = TransformPoint(currentcameraposition, nullptr, entity).y;
	float h = eye;
	if (not entity->GetAirborne() and (y < eye || eye != eyeheight)) h = Mix(y, eye, 0.25f);
	currentcameraposition = TransformPoint(0, h, 0, entity, nullptr);
	camera->SetPosition(currentcameraposition, true);


	UpdateFootsteps();

	jumpkey = false;
}


//This method will work with simple components
shared_ptr<Component> SrcPlayer::Copy()
{
	auto copy = std::make_shared<SrcPlayer>(*this);
	auto entity = GetEntity();
	if (entity)
	{
		auto world = entity->GetWorld();
		if (world) copy->camera = CreateCamera(world);
		copy->GetEntity()->extra = copy->camera;
	}
	return copy;
}

bool SrcPlayer::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Map> scene, const LoadFlags flags, shared_ptr<Object> extra)
{
	auto entity = GetEntity();
	auto world = entity->GetWorld();

	if (camera == NULL and world != NULL)
	{
		camera = CreateCamera(world);
		//camera->SetDebugPhysicsMode(true);
		camera->name = entity->name + "Camera";
		camera->Listen();

		auto pos = entity->GetPosition(true);
		camera->SetPosition(pos.x, pos.y + eyeheight, pos.z);
		camera->SetRotation(0, entity->rotation.y, 0);
		camera->SetFov(fov);

		// Push the camera to the scene.
		// This makes it so we don't have to worry about saving the camera's rotation.
		//scene->entities.push_back(camera);

		// Store the position into 
		currentcameraposition = camera->GetPosition(true);

		// Last, store the camera into this entity's extra member.
		// It's gonna be a lot easier to grab from other components this way.
		GetEntity()->extra = camera;

		// If there's no camera, we have a problem!
		Assert(camera, "SrcPlayer: Failed to create camera!");
	}

	navmesh = NULL;
	if (not scene->navmeshes.empty()) navmesh = scene->navmeshes[0];

	// Reset the look everytime we reload.
	freelookstarted = false;
	if (camera) freelookrotation = camera->GetRotation(true);

	// Load values.
	if (properties["fov"].is_number()) fov = properties["fov"];
	if (properties["eyeheight"].is_number()) eyeheight = properties["eyeheight"];
	if (properties["croucheyeheight"].is_number()) croucheyeheight = properties["croucheyeheight"];
	if (properties["mouselookspeed"].is_number()) mouselookspeed = properties["mouselookspeed"];
	if (properties["mousesmoothing"].is_number()) mousesmoothing = properties["mousesmoothing"];
	if (properties["mouselookspeed"].is_number()) mouselookspeed = properties["mouselookspeed"];
	if (properties["movespeed"].is_number()) movespeed = properties["movespeed"];
	if (properties["jumpforce"].is_number()) jumpforce = properties["jumpforce"];
	if (properties["jumplunge"].is_number()) jumplunge = properties["jumplunge"];

	// The member "enabled" is located in the base component class.
	return Player::Load(properties, binstream, scene, flags, extra);;
}

bool SrcPlayer::Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Map> scene, const SaveFlags flags, shared_ptr<Object> extra)
{
	// Store the values into the table.
	properties["fov"] = fov;
	properties["eyeheight"] = eyeheight;
	properties["croucheyeheight"] = croucheyeheight;
	properties["mousesmoothing"] = mousesmoothing;
	properties["mouselookspeed"] = mouselookspeed;
	properties["movespeed"] = movespeed;
	properties["jumpforce"] = jumpforce;
	properties["jumplunge"] = jumplunge;

	// The member "enabled" is located in the base component class.
	return Player::Save(properties, binstream, scene, flags, extra);
}
