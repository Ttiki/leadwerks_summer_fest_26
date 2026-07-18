#pragma once
#include "Leadwerks.h"

using namespace Leadwerks;

class CameraControls : public Component//Component
{
    bool freelookstarted{ false };
	Vec3 freelookrotation;
	Vec2 lookchange;
public:
	float mousesmoothing = 1.0f;//"Nouse smoothing"
	float mouselookspeed = 1.0f;//"Look speed"
	float movespeed = 4.0f;//"Move speed"
	
	CameraControls();

	virtual void Start();
	virtual bool ProcessEvent(const Event& e);
	virtual void Update();
	virtual shared_ptr<Component> Copy();
	virtual bool Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Map> scene, const LoadFlags flags, shared_ptr<Object> extra);
	virtual bool Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Map> scene, const SaveFlags flags, shared_ptr<Object> extra);
};