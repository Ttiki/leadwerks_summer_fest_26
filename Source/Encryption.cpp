#include "Leadwerks.h"
 
namespace Leadwerks
{
    void GetPassword(String& s)
    {
        s.resize(64);
        auto buffer = CreateStaticBuffer(s.Data(), s.size());
		buffer->PokeByte(8, '|');
		buffer->PokeByte(14, '&');
		buffer->PokeByte(43, '1');
		buffer->PokeByte(23, 'B');
		buffer->PokeByte(61, ')');
		buffer->PokeByte(62, 'Q');
		buffer->PokeByte(31, 'E');
		buffer->PokeByte(58, 'm');
		buffer->PokeByte(55, 'D');
		buffer->PokeByte(2, '*');
		buffer->PokeByte(25, 'r');
		buffer->PokeByte(11, 'Z');
		buffer->PokeByte(36, '*');
		buffer->PokeByte(1, 'r');
		buffer->PokeByte(0, '&');
		buffer->PokeByte(47, '{');
		buffer->PokeByte(42, '*');
		buffer->PokeByte(48, 't');
		buffer->PokeByte(60, 'J');
		buffer->PokeByte(20, 'u');
		buffer->PokeByte(30, '0');
		buffer->PokeByte(9, 'f');
		buffer->PokeByte(5, '2');
		buffer->PokeByte(18, '2');
		buffer->PokeByte(10, '?');
		buffer->PokeByte(3, 'm');
		buffer->PokeByte(46, 'L');
		buffer->PokeByte(39, '3');
		buffer->PokeByte(29, '2');
		buffer->PokeByte(57, 'F');
		buffer->PokeByte(6, 'o');
		buffer->PokeByte(44, '{');
		buffer->PokeByte(51, 'f');
		buffer->PokeByte(12, 'M');
		buffer->PokeByte(21, 'q');
		buffer->PokeByte(17, 'W');
		buffer->PokeByte(56, 'v');
		buffer->PokeByte(35, ',');
		buffer->PokeByte(7, 'E');
		buffer->PokeByte(38, 'L');
		buffer->PokeByte(16, '*');
		buffer->PokeByte(45, 'l');
		buffer->PokeByte(63, '#');
		buffer->PokeByte(4, '4');
		buffer->PokeByte(33, 'E');
		buffer->PokeByte(37, '+');
		buffer->PokeByte(13, '?');
		buffer->PokeByte(28, 'N');
		buffer->PokeByte(32, 'r');
		buffer->PokeByte(59, '5');
		buffer->PokeByte(24, 'U');
		buffer->PokeByte(54, '^');
		buffer->PokeByte(41, 'L');
		buffer->PokeByte(27, 'A');
		buffer->PokeByte(49, 'p');
		buffer->PokeByte(52, 'b');
		buffer->PokeByte(34, '}');
		buffer->PokeByte(26, ';');
		buffer->PokeByte(15, '?');
		buffer->PokeByte(40, 'H');
		buffer->PokeByte(53, 'E');
		buffer->PokeByte(50, 'b');
		buffer->PokeByte(19, 'E');
		buffer->PokeByte(22, 'y');

#ifdef _DEBUG
        //Only uncomment this for testing
        //Assert(s == "&r*m42oE|f?ZM?&?*W2EuqyBUr;AN20ErE},*+L3HL*1{lL{tpbfbE^DvFm5J)Q#");
#endif
    }
}