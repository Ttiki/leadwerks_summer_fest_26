#pragma once
#include "Leadwerks.h"
#include "MathCounter.h"

using namespace Leadwerks;

void MathCounter::Start()
{
    //Listen(EVENT_KEYDOWN, NULL);// makes this component listen for keydown events from all windows
	value = beginValue;
}

int MathCounter::Add()
{
	if (enabled)
	{
		value += addedValue;
	}
	return value;
}

int MathCounter::Subtract()
{
	if (enabled)
	{
        value -= addedValue;
	}
	return value;
}

int MathCounter::Reset()
{
	if (enabled)
	{
		value = beginValue;
	}
	return value;
}


bool MathCounter::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra)
{
	if (properties["beginValue"].is_number()) beginValue = properties["beginValue"];
	if (properties["addedValue"].is_number()) addedValue = properties["addedValue"];
	if (properties["enabled"].is_boolean()) enabled = properties["enabled"];
	if (properties["value"].is_number()) value = properties["value"];
    return BaseComponent::Load(properties, binstream, scene, flags, extra);
}

bool MathCounter::Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra)
{
	properties["beginValue"] = beginValue;
    properties["addedValue"] = addedValue;
    properties["enabled"] = enabled;
    properties["value"] = value;
    return BaseComponent::Save(properties, binstream, scene, flags, extra);
}

//This method will work with simple components
shared_ptr<Component> MathCounter::Copy()
{
    return std::make_shared<MathCounter>(*this);
}

std::any MathCounter::CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments)
{
    /*if (name == "MyMethod")
    {
        MyMethod();
        return false;
    }*/
    return BaseComponent::CallMethod(sender, name, arguments);
}