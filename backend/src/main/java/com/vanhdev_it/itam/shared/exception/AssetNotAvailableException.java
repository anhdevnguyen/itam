package com.vanhdev_it.itam.shared.exception;

public class AssetNotAvailableException extends RuntimeException {
    public AssetNotAvailableException(String assetName) {
        super("Asset [" + assetName + "] is currently unavailable and cannot be requested.");
    }
}
