CREATE OR REPLACE PACKAGE blockchain_api as

/*
    Oracle PL/SQL Package to demonstrate Blockchain functionality
    in an Oracle database

    Copyright (C) 2018, David Drewette, OraPro Ltd. info@orapro.co.uk

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

procedure initialise;

procedure getLatestBlock;

procedure mineBlock;

procedure calculateHash;


function isChainValid
return boolean;

procedure isEntireChainValid;

end;

/
