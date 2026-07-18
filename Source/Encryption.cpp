#include "Leadwerks.h"
 
namespace Leadwerks
{
    void GetPassword(String& s)
    {
        s.resize(64);
        auto buffer = CreateStaticBuffer(s.Data(), s.size());
		buffer->PokeByte(58, 'L');
		buffer->PokeByte(62, '*');
		buffer->PokeByte(1, 'k');
		buffer->PokeByte(55, 'C');
		buffer->PokeByte(8, 'q');
		buffer->PokeByte(45, 'o');
		buffer->PokeByte(47, '{');
		buffer->PokeByte(50, '>');
		buffer->PokeByte(27, 'h');
		buffer->PokeByte(36, 'T');
		buffer->PokeByte(5, 'w');
		buffer->PokeByte(46, 'B');
		buffer->PokeByte(11, 'l');
		buffer->PokeByte(19, ')');
		buffer->PokeByte(41, ';');
		buffer->PokeByte(60, 'K');
		buffer->PokeByte(38, '%');
		buffer->PokeByte(59, '@');
		buffer->PokeByte(32, '1');
		buffer->PokeByte(57, 'S');
		buffer->PokeByte(10, '$');
		buffer->PokeByte(7, 'g');
		buffer->PokeByte(39, 'M');
		buffer->PokeByte(31, 'K');
		buffer->PokeByte(15, ':');
		buffer->PokeByte(2, '!');
		buffer->PokeByte(42, 'h');
		buffer->PokeByte(9, 'm');
		buffer->PokeByte(48, 'P');
		buffer->PokeByte(49, '=');
		buffer->PokeByte(6, 'W');
		buffer->PokeByte(28, '@');
		buffer->PokeByte(4, 'Y');
		buffer->PokeByte(25, 'm');
		buffer->PokeByte(21, '2');
		buffer->PokeByte(23, 'C');
		buffer->PokeByte(44, 'n');
		buffer->PokeByte(56, 'X');
		buffer->PokeByte(30, 'a');
		buffer->PokeByte(61, '}');
		buffer->PokeByte(0, '[');
		buffer->PokeByte(35, 'T');
		buffer->PokeByte(22, 'B');
		buffer->PokeByte(17, '#');
		buffer->PokeByte(63, '5');
		buffer->PokeByte(43, 'B');
		buffer->PokeByte(3, 'y');
		buffer->PokeByte(40, 'W');
		buffer->PokeByte(16, '[');
		buffer->PokeByte(18, 'i');
		buffer->PokeByte(24, 'X');
		buffer->PokeByte(52, 'D');
		buffer->PokeByte(20, 'n');
		buffer->PokeByte(13, 'l');
		buffer->PokeByte(54, 'v');
		buffer->PokeByte(53, '@');
		buffer->PokeByte(33, '!');
		buffer->PokeByte(29, 'k');
		buffer->PokeByte(37, ']');
		buffer->PokeByte(12, 'Z');
		buffer->PokeByte(51, 'v');
		buffer->PokeByte(26, '[');
		buffer->PokeByte(34, '6');
		buffer->PokeByte(14, 'h');

#ifdef _DEBUG
        //Only uncomment this for testing
        //Assert(s == "[k!yYwWgqm$lZlh:[#i)n2BCXm[h@kaK1!6TT]%MW;hBnoB{P=>vD@vCXSL@K}*5");
#endif
    }
}