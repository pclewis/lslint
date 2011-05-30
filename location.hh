/* A Bison parser, made by GNU Bison 1.875d.  */

/* Location class for Bison C++ parsers,
   Copyright (C) 2002, 2003, 2004 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/**
 ** \file location.hh
 ** Define the Location class.
 */

#ifndef BISON_LOCATION_HH
# define BISON_LOCATION_HH

# include <iostream>
# include <string>
# include "position.hh"

namespace yy
{

  /** \brief Abstract a Location. */
  class Location
  {
    /** \name Ctor & dtor.
     ** \{ */
  public:
    /** \brief Construct a Location. */
    Location (void) :
      begin (),
      end ()
    {
    }
    /** \} */


    /** \name Line and Column related manipulators
     ** \{ */
  public:
    /** \brief Reset initial location to final location. */
    inline void step (void)
    {
      begin = end;
    }

    /** \brief Extend the current location to the COUNT next columns. */
    inline void columns (unsigned int count = 1)
    {
      end += count;
    }

    /** \brief Extend the current location to the COUNT next lines. */
    inline void lines (unsigned int count = 1)
    {
      end.lines (count);
    }
    /** \} */


  public:
    /** \brief Beginning of the located region. */
    Position begin;
    /** \brief End of the located region. */
    Position end;
  };

  /** \brief Join two Location objects to create a Location. */
  inline const Location operator+ (const Location& begin, const Location& end)
  {
    Location res = begin;
    res.end = end.end;
    return res;
  }

  /** \brief Add two Location objects */
  inline const Location operator+ (const Location& begin, unsigned int width)
  {
    Location res = begin;
    res.columns (width);
    return res;
  }

  /** \brief Add and assign a Location */
  inline Location &operator+= (Location& res, unsigned int width)
  {
    res.columns (width);
    return res;
  }

  /** \brief Intercept output stream redirection.
   ** \param ostr the destination output stream
   ** \param loc a reference to the Location to redirect
   **
   ** Avoid duplicate information.
   */
  inline std::ostream& operator<< (std::ostream& ostr, const Location& loc)
  {
    Position last = loc.end - 1;
    ostr << loc.begin;
    if (loc.begin.filename != last.filename)
      ostr << '-' << last;
    else if (loc.begin.line != last.line)
      ostr << '-' << last.line  << '.' << last.column;
    else if (loc.begin.column != last.column)
      ostr << '-' << last.column;
    return ostr;
  }

}

#endif // not BISON_LOCATION_HH
