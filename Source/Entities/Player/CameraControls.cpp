#pragma once
#include "Leadwerks.h"
#include "CameraControls.h"

using namespace Leadwerks;

CameraControls::CameraControls()
{
	//name = "CameraControls";
}

void CameraControls::Start()
{
	auto entity = GetEntity();
	Listen(EVENT_WORLDPAUSE, entity->GetWorld());
}

bool CameraControls::ProcessEvent(const Event& e)
{
	switch (e.id)
	{
	case EVENT_WORLDPAUSE:
		freelookstarted = false;
		break;
	}
	return true;
}

void CameraControls::Update()
{
	auto entity = GetEntity();
	auto window = ActiveWindow();
	if (window == NULL) return;
	iVec2 center;
	center.x = Round(window->ClientSize().x * 0.5f);
	center.y = Round(window->ClientSize().y * 0.5f);

	if (!freelookstarted)
	{
		freelookstarted = true;
		freelookrotation = entity->GetRotation(true);
		window->SetMousePosition(center.x, center.y);
	}
	auto newmousepos = window->GetMousePosition();
	window->SetMousePosition(center.x, center.y);
	float smoothfactor = 0.0f;
	if (mousesmoothing > 0.0f) smoothfactor = 1.0f - 1.0f / (1.0f + mousesmoothing);
	lookchange.x = lookchange.x * smoothfactor + (newmousepos.y - center.y) * 0.1f * mouselookspeed * (1.0f - smoothfactor);
	lookchange.y = lookchange.y * smoothfactor + (newmousepos.x - center.x) * 0.1f * mouselookspeed * (1.0f - smoothfactor);
	if (Abs(lookchange.x) < 0.001f) lookchange.x = 0.0f;
	if (Abs(lookchange.y) < 0.001f) lookchange.y = 0.0f;
	if (lookchange.x != 0.0f or lookchange.y != 0.0f)
	{
		freelookrotation.x += lookchange.x;
		freelookrotation.y += lookchange.y;
		entity->SetRotation(freelookrotation, true);
	}
	float speed = movespeed / 60.0f;
	if (window->KeyDown(KEY_SHIFT))
	{
		speed *= 10.0f;
	}
	else if (window->KeyDown(KEY_CONTROL))
	{
		speed *= 0.25f;
	}
	if (window->KeyDown(KEY_E)) entity->Translate(0, speed, 0);
	if (window->KeyDown(KEY_Q)) entity->Translate(0, -speed, 0);
	if (window->KeyDown(KEY_D)) entity->Move(speed, 0, 0);
	if (window->KeyDown(KEY_A)) entity->Move(-speed, 0, 0);
	if (window->KeyDown(KEY_W)) entity->Move(0, 0, speed);
	if (window->KeyDown(KEY_S)) entity->Move(0, 0, -speed);
}

//This method will work with simple components
shared_ptr<Component> CameraControls::Copy()
{
	return std::make_shared<CameraControls>(*this);
}

bool CameraControls::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Map> scene, const LoadFlags flags, shared_ptr<Object> extra)
{
    if (properties["mousesmoothing"].is_number()) mousesmoothing = properties["mousesmoothing"];
    if (properties["mouselookspeed"].is_number()) mouselookspeed = properties["mouselookspeed"];
    if (properties["movespeed"].is_number()) movespeed = properties["movespeed"];
	return true;
}
	
bool CameraControls::Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Map> scene, const SaveFlags flags, shared_ptr<Object> extra)
{
	properties["mousesmoothing"] = mousesmoothing;
	properties["mouselookspeed"] = mouselookspeed;
	properties["movespeed"] = movespeed;
	return true;
}