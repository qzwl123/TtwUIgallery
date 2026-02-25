
#include "stream.qpb.h"

#include <QtProtobuf/qprotobufregistration.h>

namespace routeguide {
static QtProtobuf::ProtoTypeRegistrar ProtoTypeRegistrarRequest(qRegisterProtobufType<Request>);
static QtProtobuf::ProtoTypeRegistrar ProtoTypeRegistrarResponse(qRegisterProtobufType<Response>);
static bool RegisterStreamProtobufTypes = [](){ qRegisterProtobufTypes(); return true; }();
} // namespace routeguide

