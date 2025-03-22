Meepsmongrels = RegisterMod("Meeps' Mongrels", 1)

local MeepsMongrelsScripts = {
-- HELPERS--
"enums",
"utils",
-- MONSTERS--
"tbone",
"clutchlet",
"clicketycling",
"biggun",
"raggedhanger",
"raggedgaper",
"raggedhorf",
"pallidgusher",
"lokhust",
"ragamuffin",
"lokhost",
"birdie",
}
for _, script in pairs(MeepsMongrelsScripts) do
    include("mongrels-scripts."..script)
end