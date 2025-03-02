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
}
for _, script in pairs(MeepsMongrelsScripts) do
    include("mongrels-scripts."..script)
end