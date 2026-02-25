/****************************************************************************
** Meta object code from reading C++ file 'stream.qpb.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../stream.qpb.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'stream.qpb.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.10.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN10routeguide7RequestE_t {};
} // unnamed namespace

template <> constexpr inline auto routeguide::Request::qt_create_metaobjectdata<qt_meta_tag_ZN10routeguide7RequestE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "routeguide::Request",
        "id_proto",
        "QtProtobuf::int32",
        "data"
    };

    QtMocHelpers::UintData qt_methods {
    };
    QtMocHelpers::UintData qt_properties {
        // property 'id_proto'
        QtMocHelpers::PropertyData<QtProtobuf::int32>(1, 0x80000000 | 2, QMC::DefaultPropertyFlags | QMC::Writable | QMC::EnumOrFlag | QMC::StdCppSet),
        // property 'data'
        QtMocHelpers::PropertyData<QByteArray>(3, QMetaType::QByteArray, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<Request, qt_meta_tag_ZN10routeguide7RequestE_t>(QMC::PropertyAccessInStaticMetaCall, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT static const QMetaObject::SuperData qt_meta_extradata_ZN10routeguide7RequestE[] = {
    QMetaObject::SuperData::link<QtProtobuf::staticMetaObject>(),
    nullptr
};

Q_CONSTINIT const QMetaObject routeguide::Request::staticMetaObject = { {
    QtPrivate::MetaObjectForType<QProtobufMessage>::value,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10routeguide7RequestE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10routeguide7RequestE_t>.data,
    qt_static_metacall,
    qt_meta_extradata_ZN10routeguide7RequestE,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN10routeguide7RequestE_t>.metaTypes,
    nullptr
} };

void routeguide::Request::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = reinterpret_cast<Request *>(_o);
    if (_c == QMetaObject::RegisterPropertyMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 0:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QtProtobuf::int32 >(); break;
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<QtProtobuf::int32*>(_v) = _t->id_proto(); break;
        case 1: *reinterpret_cast<QByteArray*>(_v) = _t->data(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setId_proto(*reinterpret_cast<QtProtobuf::int32*>(_v)); break;
        case 1: _t->setData(*reinterpret_cast<QByteArray*>(_v)); break;
        default: break;
        }
    }
}
namespace {
struct qt_meta_tag_ZN10routeguide8ResponseE_t {};
} // unnamed namespace

template <> constexpr inline auto routeguide::Response::qt_create_metaobjectdata<qt_meta_tag_ZN10routeguide8ResponseE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "routeguide::Response",
        "message"
    };

    QtMocHelpers::UintData qt_methods {
    };
    QtMocHelpers::UintData qt_properties {
        // property 'message'
        QtMocHelpers::PropertyData<QString>(1, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<Response, qt_meta_tag_ZN10routeguide8ResponseE_t>(QMC::PropertyAccessInStaticMetaCall, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject routeguide::Response::staticMetaObject = { {
    QtPrivate::MetaObjectForType<QProtobufMessage>::value,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10routeguide8ResponseE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10routeguide8ResponseE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN10routeguide8ResponseE_t>.metaTypes,
    nullptr
} };

void routeguide::Response::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = reinterpret_cast<Response *>(_o);
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<QString*>(_v) = _t->message(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setMessage(*reinterpret_cast<QString*>(_v)); break;
        default: break;
        }
    }
}
namespace {
struct qt_meta_tag_ZN10routeguide24Request_QtProtobufNestedE_t {};
} // unnamed namespace

template <> constexpr inline auto routeguide::Request_QtProtobufNested::qt_create_metaobjectdata<qt_meta_tag_ZN10routeguide24Request_QtProtobufNestedE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "routeguide::Request_QtProtobufNested",
        "QtProtobufFieldEnum",
        "Id_protoProtoFieldNumber",
        "DataProtoFieldNumber"
    };

    QtMocHelpers::UintData qt_methods {
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
        // enum 'QtProtobufFieldEnum'
        QtMocHelpers::EnumData<QtProtobufFieldEnum>(1, 1, QMC::EnumIsScoped).add({
            {    2, QtProtobufFieldEnum::Id_protoProtoFieldNumber },
            {    3, QtProtobufFieldEnum::DataProtoFieldNumber },
        }),
    };
    return QtMocHelpers::metaObjectData<void, qt_meta_tag_ZN10routeguide24Request_QtProtobufNestedE_t>(QMC::PropertyAccessInStaticMetaCall, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}

static constexpr auto qt_staticMetaObjectContent_ZN10routeguide24Request_QtProtobufNestedE =
    routeguide::Request_QtProtobufNested::qt_create_metaobjectdata<qt_meta_tag_ZN10routeguide24Request_QtProtobufNestedE_t>();
static constexpr auto qt_staticMetaObjectStaticContent_ZN10routeguide24Request_QtProtobufNestedE =
    qt_staticMetaObjectContent_ZN10routeguide24Request_QtProtobufNestedE.staticData;
static constexpr auto qt_staticMetaObjectRelocatingContent_ZN10routeguide24Request_QtProtobufNestedE =
    qt_staticMetaObjectContent_ZN10routeguide24Request_QtProtobufNestedE.relocatingData;

Q_CONSTINIT const QMetaObject routeguide::Request_QtProtobufNested::staticMetaObject = { {
    nullptr,
    qt_staticMetaObjectStaticContent_ZN10routeguide24Request_QtProtobufNestedE.stringdata,
    qt_staticMetaObjectStaticContent_ZN10routeguide24Request_QtProtobufNestedE.data,
    nullptr,
    nullptr,
    qt_staticMetaObjectRelocatingContent_ZN10routeguide24Request_QtProtobufNestedE.metaTypes,
    nullptr
} };

namespace {
struct qt_meta_tag_ZN10routeguide25Response_QtProtobufNestedE_t {};
} // unnamed namespace

template <> constexpr inline auto routeguide::Response_QtProtobufNested::qt_create_metaobjectdata<qt_meta_tag_ZN10routeguide25Response_QtProtobufNestedE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "routeguide::Response_QtProtobufNested",
        "QtProtobufFieldEnum",
        "MessageProtoFieldNumber"
    };

    QtMocHelpers::UintData qt_methods {
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
        // enum 'QtProtobufFieldEnum'
        QtMocHelpers::EnumData<QtProtobufFieldEnum>(1, 1, QMC::EnumIsScoped).add({
            {    2, QtProtobufFieldEnum::MessageProtoFieldNumber },
        }),
    };
    return QtMocHelpers::metaObjectData<void, qt_meta_tag_ZN10routeguide25Response_QtProtobufNestedE_t>(QMC::PropertyAccessInStaticMetaCall, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}

static constexpr auto qt_staticMetaObjectContent_ZN10routeguide25Response_QtProtobufNestedE =
    routeguide::Response_QtProtobufNested::qt_create_metaobjectdata<qt_meta_tag_ZN10routeguide25Response_QtProtobufNestedE_t>();
static constexpr auto qt_staticMetaObjectStaticContent_ZN10routeguide25Response_QtProtobufNestedE =
    qt_staticMetaObjectContent_ZN10routeguide25Response_QtProtobufNestedE.staticData;
static constexpr auto qt_staticMetaObjectRelocatingContent_ZN10routeguide25Response_QtProtobufNestedE =
    qt_staticMetaObjectContent_ZN10routeguide25Response_QtProtobufNestedE.relocatingData;

Q_CONSTINIT const QMetaObject routeguide::Response_QtProtobufNested::staticMetaObject = { {
    nullptr,
    qt_staticMetaObjectStaticContent_ZN10routeguide25Response_QtProtobufNestedE.stringdata,
    qt_staticMetaObjectStaticContent_ZN10routeguide25Response_QtProtobufNestedE.data,
    nullptr,
    nullptr,
    qt_staticMetaObjectRelocatingContent_ZN10routeguide25Response_QtProtobufNestedE.metaTypes,
    nullptr
} };

QT_WARNING_POP
