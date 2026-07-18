#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class ChangeEmission : public BaseComponent//Component
{
public: 
    bool recursive = false;//"Recursive"
    Vec3 color0;//"Color 1" COLOR
    Vec3 color1;//"Color 2" COLOR
    Vec3 color2;//"Color 3" COLOR
    WString soundfile;//"Sound file" SOUND
    float soundvolume = 100;//"Sound volume"
    float soundrange = 1000;//"Sound range"
    bool once = true;//"Use once"
    shared_ptr<Sound> sound;

    ChangeEmission();
	
	/*
	virtual void SetColor1();//in
	virtual void SetColor2();//in
	virtual void SetColor3();//in
	*/

    virtual std::any CallMethod(shared_ptr<Component> caller, const WString& name, const std::vector<std::any>& args);
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
};