/****************************************************************************
** Meta object code from reading C++ file 'stream.qpb.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.3)
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
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.8.3. It"
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


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN10routeguide7RequestE = QtMocHelpers::stringData(
    "routeguide::Request",
    "id_proto",
    "QtProtobuf::int32",
    "data"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN10routeguide7RequestE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       2,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // properties: name, type, flags, notifyId, revision
       1, 0x80000000 | 2, 0x0001510b, uint(-1), 0,
       3, QMetaType::QByteArray, 0x00015103, uint(-1), 0,

       0        // eod
};

Q_CONSTINIT static const QMetaObject::SuperData qt_meta_extradata_ZN10routeguide7RequestE[] = {
    QMetaObject::SuperData::link<QtProtobuf::staticMetaObject>(),
    nullptr
};

Q_CONSTINIT const QMetaObject routeguide::Request::staticMetaObject = { {
    QtPrivate::MetaObjectForType<QProtobufMessage>::value,
    qt_meta_stringdata_ZN10routeguide7RequestE.offsetsAndSizes,
    qt_meta_data_ZN10routeguide7RequestE,
    qt_static_metacall,
    qt_meta_extradata_ZN10routeguide7RequestE,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN10routeguide7RequestE_t,
        // property 'id_proto'
        QtPrivate::TypeAndForceComplete<QtProtobuf::int32, std::true_type>,
        // property 'data'
        QtPrivate::TypeAndForceComplete<QByteArray, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<Request, std::true_type>
    >,
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
        case 0: *reinterpret_cast< QtProtobuf::int32*>(_v) = _t->id_proto(); break;
        case 1: *reinterpret_cast< QByteArray*>(_v) = _t->data(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setId_proto(*reinterpret_cast< QtProtobuf::int32*>(_v)); break;
        case 1: _t->setData(*reinterpret_cast< QByteArray*>(_v)); break;
        default: break;
        }
    }
}
namespace {
struct qt_meta_tag_ZN10routeguide8ResponseE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN10routeguide8ResponseE = QtMocHelpers::stringData(
    "routeguide::Response",
    "message"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN10routeguide8ResponseE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       1,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // properties: name, type, flags, notifyId, revision
       1, QMetaType::QString, 0x00015103, uint(-1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject routeguide::Response::staticMetaObject = { {
    QtPrivate::MetaObjectForType<QProtobufMessage>::value,
    qt_meta_stringdata_ZN10routeguide8ResponseE.offsetsAndSizes,
    qt_meta_data_ZN10routeguide8ResponseE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN10routeguide8ResponseE_t,
        // property 'message'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<Response, std::true_type>
    >,
    nullptr
} };

void routeguide::Response::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = reinterpret_cast<Response *>(_o);
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->message(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setMessage(*reinterpret_cast< QString*>(_v)); break;
        default: break;
        }
    }
}
namespace {
struct qt_meta_tag_ZN10routeguide24Request_QtProtobufNestedE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN10routeguide24Request_QtProtobufNestedE = QtMocHelpers::stringData(
    "routeguide::Request_QtProtobufNested",
    "QtProtobufFieldEnum",
    "Id_protoProtoFieldNumber",
    "DataProtoFieldNumber"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN10routeguide24Request_QtProtobufNestedE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       1,   14, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // enums: name, alias, flags, count, data
       1,    1, 0x2,    2,   19,

 // enum data: key, value
       2, uint(routeguide::Request_QtProtobufNested::QtProtobufFieldEnum::Id_protoProtoFieldNumber),
       3, uint(routeguide::Request_QtProtobufNested::QtProtobufFieldEnum::DataProtoFieldNumber),

       0        // eod
};

Q_CONSTINIT const QMetaObject routeguide::Request_QtProtobufNested::staticMetaObject = { {
    nullptr,
    qt_meta_stringdata_ZN10routeguide24Request_QtProtobufNestedE.offsetsAndSizes,
    qt_meta_data_ZN10routeguide24Request_QtProtobufNestedE,
    nullptr,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN10routeguide24Request_QtProtobufNestedE_t,
        // enum 'QtProtobufFieldEnum'
        QtPrivate::TypeAndForceComplete<Request_QtProtobufNested::QtProtobufFieldEnum, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<void, std::true_type>
    >,
    nullptr
} };

namespace {
struct qt_meta_tag_ZN10routeguide25Response_QtProtobufNestedE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN10routeguide25Response_QtProtobufNestedE = QtMocHelpers::stringData(
    "routeguide::Response_QtProtobufNested",
    "QtProtobufFieldEnum",
    "MessageProtoFieldNumber"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN10routeguide25Response_QtProtobufNestedE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       1,   14, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // enums: name, alias, flags, count, data
       1,    1, 0x2,    1,   19,

 // enum data: key, value
       2, uint(routeguide::Response_QtProtobufNested::QtProtobufFieldEnum::MessageProtoFieldNumber),

       0        // eod
};

Q_CONSTINIT const QMetaObject routeguide::Response_QtProtobufNested::staticMetaObject = { {
    nullptr,
    qt_meta_stringdata_ZN10routeguide25Response_QtProtobufNestedE.offsetsAndSizes,
    qt_meta_data_ZN10routeguide25Response_QtProtobufNestedE,
    nullptr,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN10routeguide25Response_QtProtobufNestedE_t,
        // enum 'QtProtobufFieldEnum'
        QtPrivate::TypeAndForceComplete<Response_QtProtobufNested::QtProtobufFieldEnum, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<void, std::true_type>
    >,
    nullptr
} };

QT_WARNING_POP
