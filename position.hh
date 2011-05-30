/* A Bison parser, made by GNU Bison 1.875d.  */

/* Position class for Bison C++ parsers,
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
 ** \file position.hh
 ** Define the Location class.
 */

#ifndef BISON_POSITION_HH
# define BISON_POSITION_HH

# include <iostream>
# include <string>

namespace yy
{
  /** \brief Abstract a Position. */
  class Position
  {
  public:
    /** \brief Initial column number. */
    static const unsigned int initial_column = 0;
    /** \brief Initial line number. */
    static const unsigned int initial_line = 1;

    /** \name Ctor & dtor.
     ** \{ */
  public:
    /** \brief Construct a Position. */
    Position () :
      filename (),
      line (initial_line),
      column (initial_column)
    {
    }
    /** \} */


    /** \name Line and Column related manipulators
     ** \{ */
  public:
    /** \brief (line related) Advance to the COUNT next lines. */
    inline void lines (int count = 1)
    {
      column = initial_column;
      line += count;
    }

    /** \brief (column related) Advance to the COUNT next columns. */
    inline void columns (int count = 1)
    {
      int leftmost = initial_column;
      int current  = column;
      if (leftmost <= current + count)
	column += count;
      else
	column = initial_column;
    }
    /** \} */

  public:
    /** \brief File name to which this position refers. */
    std::string filename;
    /** \brief Current line number. */
    unsigned int line;
    /** \brief Current column number. */
    unsigned int column;
  };

  /** \brief Add and assign a Position. */
  inline const Position&
  operator+= (Position& res, const int width)
  {
    res.columns (width);
    return res;
  }

  /** \brief Add two Position objects. */
  inline const Position
  operator+ (const Position& begin, const int width)
  {
    Position res = begin;
    return res += width;
  }

  /** \brief Add and assign a Position. */
  inline const Position&
  operator-= (Position& res, const int width)
  {
    return res += -width;
  }

  /** \brief Add two Position objects. */
  inline const Position
  operator- (const Position& begin, const int width)
  {
    return begin + -width;
  }

  /** \brief Intercept output stream redirection.
   ** \param ostr the destination output stream
   ** \param pos a reference to the Position to redirect
   */
  inline std::ostream&
  operator<< (std::ostream& ostr, const Position& pos)
  {
    if (!pos.filename.empty ())
      ostr << pos.filename << ':';
    return ostr << pos.line << '.' << pos.column;
  }

}
#endif // not BISON_POSITION_HH
