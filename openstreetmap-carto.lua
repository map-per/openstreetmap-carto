-- For documentation of Lua tag transformations, see:
-- https://github.com/openstreetmap/osm2pgsql/blob/master/docs/lua.md

-- Custom keys that are defined by this file
custom_keys = {'z_order', 'osmcarto_z_order'}

-- Objects with any of the following keys will be treated as polygon
local polygon_keys = {
   'building', 'landuse', 'amenity', 'harbour', 'historic', 'leisure',
   'man_made', 'military', 'natural', 'office', 'place', 'power',
   'public_transport', 'shop', 'sport', 'tourism', 'waterway',
   'wetland', 'water', 'aeroway', 'abandoned:aeroway', 'abandoned:amenity',
   'abandoned:building', 'abandoned:landuse', 'abandoned:power', 'area:highway'
}


-- Objects with any of the following key/value combinations will be treated as linestring
local linestring_values = {
   leisure = {track = true},
   man_made = {embankment = true, breakwater = true, groyne = true},
   natural = {cliff = true, tree_row = true},
   historic = {citywalls = true},
   waterway = {canal = true, derelict_canal = true, ditch = true, drain = true, river = true, stream = true, wadi = true, weir = true},
   power = {line = true, minor_line = true}
}

-- Objects with any of the following key/value combinations will be treated as polygon
local polygon_values = {
   highway = {services = true, rest_area = true},
   junction = {yes = true}
}

-- The following keys will be deleted
delete_tags = {
  'note',
  'source',
  'source_ref',
  'attribution',
  'comment',
  'fixme',
  -- Tags generally dropped by editors, not otherwise covered
  'created_by',
  'odbl',
  'odbl:note',
  -- Lots of import tags
  -- EUROSHA (Various countries)
  'project:eurosha_2012',

  -- UrbIS (Brussels, BE)
  'ref:UrbIS',

  -- NHN (CA)
  'accuracy:meters',
  'sub_sea:type',
  'waterway:type',
  -- StatsCan (CA)
  'statscan:rbuid',

  -- RUIAN (CZ)
  'ref:ruian:addr',
  'ref:ruian',
  'building:ruian:type',
  -- DIBAVOD (CZ)
  'dibavod:id',
  -- UIR-ADR (CZ)
  'uir_adr:ADRESA_KOD',

  -- GST (DK)
  'gst:feat_id',

  -- Maa-amet (EE)
  'maaamet:ETAK',
  -- FANTOIR (FR)
  'ref:FR:FANTOIR',

  -- 3dshapes (NL)
  '3dshapes:ggmodelk',
  -- AND (NL)
  'AND_nosr_r',

  -- OPPDATERIN (NO)
  'OPPDATERIN',
  -- Various imports (PL)
  'addr:city:simc',
  'addr:street:sym_ul',
  'building:usage:pl',
  'building:use:pl',
  -- TERYT (PL)
  'teryt:simc',

  -- RABA (SK)
  'raba:id',
  -- DCGIS (Washington DC, US)
  'dcgis:gis_id',
  -- Building Identification Number (New York, US)
  'nycdoitt:bin',
  -- Chicago Building Inport (US)
  'chicago:building_id',
  -- Louisville, Kentucky/Building Outlines Import (US)
  'lojic:bgnum',
  -- MassGIS (Massachusetts, US)
  'massgis:way_id',

  -- mvdgis (Montevideo, UY)
  'mvdgis:.*',

  -- misc
  'import',
  'import_uuid',
  'OBJTYPE',
  'SK53_bulk:load'
}
delete_wildcards = {
  'note:.*',
  'source:.*',
  -- Corine (CLC) (Europe)
  'CLC:.*',

  -- Geobase (CA)
  'geobase:.*',
  -- CanVec (CA)
  'canvec:.*',
  -- Geobase (CA)
  'geobase:.*',

  -- osak (DK)
  'osak:.*',
  -- kms (DK)
  'kms:.*',

  -- ngbe (ES)
  -- See also note:es and source:file above
  'ngbe:.*',

 -- Friuli Venezia Giulia (IT)
  'it:fvg:.*',

  -- KSJ2 (JA)
  -- See also note:ja and source_ref above
  'KSJ2:.*',
  -- Yahoo/ALPS (JA)
  'yh:.*',

  -- LINZ (NZ)
  'LINZ2OSM:.*',
  'linz2osm:.*',
  'LINZ:.*',

  -- WroclawGIS (PL)
  'WroclawGIS:.*',
  -- Naptan (UK)
  'naptan:.*',

  -- TIGER (US)
  'tiger:.*',
  -- GNIS (US)
  'gnis:.*',
  -- National Hydrography Dataset (US)
  'NHD:.*',
  'nhd:.*',
  -- mvdgis (Montevideo, UY)
  'mvdgis:.*'

}

-- Big table for z_order and roads status for certain tags. z=0 is turned into
-- nil by the z_order function
local roads_info = {
    highway = {
        motorway        = {z = 380, roads = true},
        trunk           = {z = 370, roads = true},
        primary         = {z = 360, roads = true},
        secondary       = {z = 350, roads = true},
        tertiary        = {z = 340, roads = false},
        residential     = {z = 330, roads = false},
        unclassified    = {z = 330, roads = false},
        road            = {z = 330, roads = false},
        living_street   = {z = 320, roads = false},
        pedestrian      = {z = 310, roads = false},
        raceway         = {z = 300, roads = false},
        motorway_link   = {z = 240, roads = true},
        trunk_link      = {z = 230, roads = true},
        primary_link    = {z = 220, roads = true},
        secondary_link  = {z = 210, roads = true},
        tertiary_link   = {z = 200, roads = false},
        service         = {z = 150, roads = false},
        track           = {z = 110, roads = false},
        path            = {z = 100, roads = false},
        footway         = {z = 100, roads = false},
        bridleway       = {z = 100, roads = false},
        cycleway        = {z = 100, roads = false},
        steps           = {z = 90, roads = false},
        platform        = {z = 90, roads = false},
        construction    = {z = 10, roads = false}
    },
    railway = {
        rail            = {z = 440, roads = true},
        subway          = {z = 420, roads = true},
        narrow_gauge    = {z = 420, roads = true},
        light_rail      = {z = 420, roads = true},
        preserved       = {z = 420, roads = true},
        funicular       = {z = 420, roads = true},
        monorail        = {z = 420, roads = true},
        miniature       = {z = 420, roads = true},
        turntable       = {z = 420, roads = true},
        tram            = {z = 410, roads = true},
        disused         = {z = 400, roads = true},
        construction    = {z = 400, roads = true},
        platform        = {z = 90, roads = true},
    },
    aeroway = {
        runway          = {z = 60, roads = false},
        taxiway         = {z = 50, roads = false},
    },
    boundary = {
        administrative  = {z = 0, roads = true}
    },
}

--- Gets the z_order for a set of tags
-- @param tags OSM tags
-- @return z_order if an object with z_order, otherwise nil
function z_order(tags)
    local z = 0
    for k, v in pairs(tags) do
        if roads_info[k] and roads_info[k][v] then
            z = math.max(z, roads_info[k][v].z)
        end
    end
    return z ~= 0 and z or nil
end

--- Gets the roads table status for a set of tags
-- @param tags OSM tags
-- @return 1 if it belongs in the roads table, 0 otherwise
function roads(tags)
    for k, v in pairs(tags) do
        if roads_info[k] and roads_info[k][v] and roads_info[k][v].roads then
            return 1
        end
    end
    return 0
end

-- Filtering on nodes, ways, and relations
function filter_tags_generic(tags, n)
   -- Delete tags listed in delete_tags
   for tag, _ in pairs (tags) do
      for _, d in ipairs(delete_tags) do
         if tag == d then
            tags[tag] = nil
            break -- Skip this tag from further checks since it's deleted
         end
      end
   end
   -- By using a second loop for wildcards we avoid checking already deleted tags
   for tag, _ in pairs (tags) do
      for _, d in ipairs(delete_wildcards) do
         if string.find(tag, d) then
            tags[tag] = nil
            break
         end
      end
   end

   -- Filter out objects that have no tags after deleting
   if next(tags) == nil then
      return 1, {}
   end

   -- Convert layer to an integer
   tags['layer'] = layer(tags['layer'])
   return 0, tags
end

-- Filtering on nodes
function filter_tags_node (keyvalues, numberofkeys)
   return filter_tags_generic(keyvalues, numberofkeys)
end

-- Filtering on relations
function filter_basic_tags_rel (keyvalues, numberofkeys)
   -- Filter out objects that are filtered out by filter_tags_generic
   local filter, keyvalues = filter_tags_generic(keyvalues, numberofkeys)
   if filter == 1 then
      return 1, keyvalues
   end

   -- Filter out all relations except route, multipolygon and boundary relations
   if ((keyvalues["type"] ~= "route") and (keyvalues["type"] ~= "multipolygon") and (keyvalues["type"] ~= "boundary")) then
      return 1, keyvalues
   end

   return 0, keyvalues
end

-- Filtering on ways
function filter_tags_way (keyvalues, numberofkeys)
   local filter = 0  -- Will object be filtered out?
   local polygon = 0 -- Will object be treated as polygon?

   -- Filter out objects that are filtered out by filter_tags_generic
   filter, keyvalues = filter_tags_generic(keyvalues, numberofkeys)
   if filter == 1 then
      return filter, keyvalues, polygon, roads
   end

   polygon = isarea(keyvalues)

   -- Add z_order column
   keyvalues.z_order = z_order(keyvalues)

   return filter, keyvalues, polygon, roads(keyvalues)
end

function filter_tags_relation_member (keyvalues, keyvaluemembers, roles, membercount)
   local filter = 0     -- Will object be filtered out?
   local linestring = 0 -- Will object be treated as linestring?
   local polygon = 0    -- Will object be treated as polygon?
   local membersuperseded = {}
   for i = 1, membercount do
      membersuperseded[i] = 0 -- Will member be ignored when handling areas?
   end

   local type = keyvalues["type"]

   -- Remove type key
   keyvalues["type"] = nil

   -- Boundary relations are treated as linestring
   if type == "boundary" or (type == "multipolygon" and keyvalues["boundary"]) then
      linestring = 1
   -- For multipolygons...
   elseif (type == "multipolygon") then
      -- Treat as polygon
      polygon = 1

      -- Support for old-style multipolygons (1/2):
      -- If there are no polygon tags, add tags from all outer elements to the multipolygon itself
      haspolytags = isarea(keyvalues)
      if (haspolytags == 0) then
         for i = 1,membercount do
            if (roles[i] == "outer") then
               for k,v in pairs(keyvaluemembers[i]) do
                  keyvalues[k] = v
               end
            end
         end
      end
      -- Support for old-style multipolygons (2/2):
      -- For any member of the multipolygon, set membersuperseded to 1 (i.e. don't deal with it as area as well),
      -- except when the member has a (non-custom) key/value combination that is not also a key/value combination of the multipolygon itself
      for i = 1,membercount do
         superseded = 1
         for k,v in pairs(keyvaluemembers[i]) do
            if ((keyvalues[k] == nil or keyvalues[k] ~= v) and not is_in(k,custom_keys)) then
              superseded = 0;
              break
            end
         end
         membersuperseded[i] = superseded
      end
   end

   -- Add z_order column
   keyvalues.z_order = z_order(keyvalues)

   return filter, keyvalues, membersuperseded, linestring, polygon, roads(keyvalues)
end

--- Check if an object with given tags should be treated as polygon
-- @param tags OSM tags
-- @return 1 if area, 0 if linear
function isarea (tags)
   -- Treat objects tagged as area=yes polygon, other area as no
   if tags["area"] then
      return tags["area"] == "yes" and 1 or 0
   end

   -- Search through object's tags
   for k, v in pairs(tags) do
      -- Check if it has a polygon key and not a linestring override, or a polygon k=v
      for _, ptag in ipairs(polygon_keys) do
         if k == ptag and not (linestring_values[k] and linestring_values[k][v]) then
            return 1
         end
      end

      if (polygon_values[k] and polygon_values[k][v]) then
         return 1
      end
   end
   return 0
end

function is_in (needle, haystack)
    for index, value in ipairs (haystack) do
        if value == needle then
            return true
        end
    end
    return false
end

--- Normalizes layer tags
-- @param v The layer tag value
-- @return An integer for the layer tag
function layer (v)
    return v and string.find(v, "^-?%d+$") and tonumber(v) < 100 and tonumber(v) > -100 and v or nil
end
