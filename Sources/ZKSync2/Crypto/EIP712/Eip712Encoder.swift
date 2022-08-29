//
//  File.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 8/16/22.
//

//public class Eip712Encoder {
//    public static Bytes32 encodeValue(Type<?> value) {
//        if (value instanceof Utf8String) {
//            Utf8String s = (Utf8String) value;
//            return new Bytes32(Hash.sha3(s.getValue().getBytes()));
//        } else if (value instanceof Bytes32) {
//            return (Bytes32) value;
//        } else if (value instanceof NumericType) {
//            NumericType nt = (NumericType) value;
//            return new Bytes32(Numeric.toBytesPadded(nt.getValue(), 32));
//        } else if (value instanceof BytesType) {
//            BytesType bt = (BytesType) value;
//            byte[] bytes = Hash.sha3(bt.getValue());
//            return new Bytes32(bytes);
//        } else if (value instanceof Address) {
//            Address address = (Address) value;
//            byte[] bytes = Numeric.hexStringToByteArray(address.getValue());
//            byte[] result = new byte[32];
//            System.arraycopy(bytes, 0, result, 12, 20);
//            return new Bytes32(result);
//        } else if (value instanceof Eip712Struct) {
//            Eip712Struct struct = (Eip712Struct) value;
//            byte[] typeHash = typeHash(struct);
//            List<Pair<String, Type<?>>> members = struct.getValue().eip712types();
//            ByteBuffer bytes = ByteBuffer.allocate((members.size() + 1) * 32);
//            bytes.put(typeHash);
//            for (Pair<String, Type<?>> member : members) {
//                Bytes32 result = encodeValue(member.getValue());
//                bytes.put(result.getValue());
//            }
//            return new Bytes32(Hash.sha3(bytes.array()));
//        } else {
//            throw new IllegalArgumentException("Unsupported ethereum type");
//        }
//    }
//
//    public static String encodeType(Eip712Struct structure) {
//        StringBuilder sb = new StringBuilder(structure.encodeType());
//        dependencies(structure).forEach(value -> sb.append(value.encodeType()));
//
//        return sb.toString();
//    }
//
//    public static byte[] typeHash(Eip712Struct structure) {
//        return Hash.sha3(encodeType(structure).getBytes());
//    }
//
//    public static Set<Eip712Struct> dependencies(Eip712Struct structure) {
//        final TreeSet<Eip712Struct> result = new TreeSet<>();
//        for (Pair<String, Type<?>> value : structure.getValue().eip712types()) {
//            if (value.getValue() instanceof Eip712Struct) {
//                result.add((Eip712Struct) value.getValue());
//            }
//        }
//
//        return result;
//    }
//
//    public static <S extends Structurable> byte[] typedDataToSignedBytes(Eip712Domain domain, S typedData) {
//        final ByteArrayOutputStream output = new ByteArrayOutputStream();
//
//        try {
//            output.write(EthSigner.MESSAGE_EIP712_PREFIX.getBytes());
//            output.write(Eip712Encoder.encodeValue(domain.intoEip712Struct()).getValue());
//            output.write(Eip712Encoder.encodeValue(typedData.intoEip712Struct()).getValue());
//        } catch (IOException e) {
//            throw new IllegalStateException("Error when creating ETH signature", e);
//        }
//
//        return Hash.sha3(output.toByteArray());
//    }
//}

import Foundation

// ZKSync2 (Java): Eip712Encoder.java
class Eip712Encoder {
    
}
