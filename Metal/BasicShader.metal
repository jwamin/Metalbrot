//
//  Basic.metal
//  MetalFromTheTop
//
//  Created by Joss Manger on 11/23/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

#include "MetalHeaders.h"

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
  
  //define vertexOut struct
  VertexOut out;
  
  //get xy position from vertex in
  out.position = float4(vertex_in.position,0.0,1.0);
  
  //assign color to vertex out but vertex index
  out.color = vertex_in.color;
  
  //pass vertex on
  return out;
  
};

fragment float4 fragment_main(VertexOut in [[stage_in]]) {

  //pass on color to fragment
  return in.color;

}
