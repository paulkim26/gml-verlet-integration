#define update_verlet
//update_verlet()
var iteration_count;
iteration_count = 10 //1+ higher iteration count increases structural rigidity

update_points()
repeat iteration_count {
    update_sticks()
    constrain_points()
}

#define create_point
//create_point(x,y,xspeed,yspeed,pinned)
var point;
point = instance_create(argument0,argument1,obj_point)
with point {
    oldx = x - argument2
    oldy = y - argument3
    pinned = argument4
    
    bounce = 0.5
    gravity_strength = 0.2
}
return point

#define update_points
//update_points()
with obj_point {
    if !pinned {
        var vx,vy;
        vx = (x - oldx)
        vy = (y - oldy)
        
        oldx = x
        oldy = y
        x += vx
        y += vy
        y += gravity_strength
    }
}

#define constrain_points
//constrain_points()
with obj_point {
    if !pinned {
        var vx,vy;
        vx = (x - oldx)
        vy = (y - oldy)
    
        //room boundary collision
        var w,h;
        w = room_width - 1
        h = room_height - 1
        
        if x > w {
            x = w
            oldx = x + vx * bounce
        }
        if x < 0 {
            x = 0
            oldx = x + vx * bounce
        }
        if y > h {
            y = h
            oldy = y + vy * bounce
        }
        if y < 0 {
            y = 0
            oldy = y + vy * bounce
        }
    }
}

#define create_stick
//create_stick(point1,point2,rope)
var stick;
stick = instance_create(0,0,obj_stick)
with stick {
    point0 = argument0
    point1 = argument1
    rope = argument2
    length = point_distance(point0.x,point0.y,point1.x,point1.y)
}
return stick

#define update_sticks
//update_sticks()
with obj_stick {
    dx = point1.x - point0.x
    dy = point1.y - point0.y
    distance = sqrt(dx * dx + dy * dy)
    difference = length - distance
    
    if distance = 0
    percent = 0
    else
    percent = difference / distance / 2
    
    offsetx = dx * percent
    offsety = dy * percent
    
    //if acting like a rope, stick will push back points that get close to each other
    if rope {
        if distance < length {
            offsetx = 0
            offsety = 0
        }
    }
    
    //manipulate point position
    if !point0.pinned {
        point0.x -= offsetx
        point0.y -= offsety
    }
    if !point1.pinned {
        point1.x += offsetx
        point1.y += offsety
    }
}

#define create_chain
//create_chain(x1,y1,x2,y2,chain_links,link_length,rope)
var x1,y1,x2,y2,chain_links,link_length,rope;
x1 = argument0
y1 = argument1
x2 = argument2
y2 = argument3
chain_links = argument4
link_length = argument5
rope = argument6

var chain_length;
chain_length = point_distance(x1,y1,x2,y2)

if link_length = -1 {
    link_length = chain_length/chain_links
}

//return
first_point = create_point(x1,y1,0,0,0)

var prev_point;
prev_point = first_point
for (i = 1; i < chain_links; i += 1) {
    var percent;
    percent = i/(chain_links - 1)
    var xx,yy;
    xx = x1*(1-percent) + x2*(percent)
    yy = y1*(1-percent) + y2*(percent)

    var point;
    point = create_point(xx,yy,0,0,0)
    var stick;
    stick = create_stick(prev_point,point,rope)
    stick.length = link_length
    
    prev_point = point
}
//return
last_point = point




#define create_box
//create_box(x,y,w,h)
var box;
box = instance_create(argument0,argument1,obj_box)
with box {
    w = argument2
    h = argument3
    
    p1 = create_point(x - w/2,y - h/2,0,0,0)
    p2 = create_point(x + w/2,y - h/2,0,0,0)
    p3 = create_point(x - w/2,y + h/2,0,0,0)
    p4 = create_point(x + w/2,y + h/2,0,0,0)
    create_stick(p1,p2,0)
    create_stick(p1,p3,0)
    create_stick(p2,p4,0)
    create_stick(p3,p4,0)
    create_stick(p1,p4,0)
}
return box

#define create_cloth


//create_cloth(x,y,w,h,res_w,res_h)
var cloth;
cloth = instance_create(argument0,argument1,obj_cloth)

with (cloth) {
    w = argument2
    h = argument3
    res_w = argument4
    res_h = argument5
    
    for (j = 0; j < res_h; j += 1) {            
        for (i = 0; i < res_w; i += 1) {
            var point;
            
            var xx,yy;
            xx = x - w/2 + (i/res_w) * w
            yy = y - h/2 + (j/res_h) * h
            point = create_point(xx,yy,0,0,0)
            cloth_array[i,j] = point
            
            //pin
            if i = 0 and j = 0
            point.pinned = true
            if i = res_w - 1 and j = 0
            point.pinned = true
            
            if i > 0
            create_stick(point,cloth_array[i - 1,j],1)
            if j > 0
            create_stick(point,cloth_array[i,j - 1],1)
            
            if 0 {
                //cross brace 1
                if i > 0 and j > 0
                create_stick(point,cloth_array[i - 1,j - 1],1)
                //cross brace 2
                if i < (res_w - 1) and j > 0
                create_stick(point,cloth_array[i + 1,j - 1],1)
            }
        }
    }
}

return cloth

