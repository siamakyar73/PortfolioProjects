/*

Cleaning Data in SQL

*/

select *
From PortfolioProject.dbo.NashvilleHousing


-- Standardize Data Format

select SaleDate, Convert(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing


/*
--Sometimes the following doesn't work.

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

--So we use the ALTER function
*/

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted  = Convert(Date, SaleDate)


select SaleDate, SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

--Populate property address data

--I want to check the property addresses and try to fill the null values with the correct values.

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a. UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a. UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null



--How to split the property address into address and city


Select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortfolioProject.dbo.NashvilleHousing


--How to use PARSENAME (This function reads and splits based on periods instead of commas. So we have to replace commas with periods)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



Select OwnerAddress, OwnerSplitAddress, OwnerSplitAddress, OwnerSplitState
From PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant= 'Y' THEN 'Yes'
			       when SoldAsVacant= 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END


Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


--Remove Duplicates (How to impelement CTE)

With RowNumCTE AS(
select *,
ROW_NUMBER() OVER(
				  Partition By ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order By
				  UniqueID
				  ) row_num
From PortfolioProject.dbo.NashvilleHousing
)

Delete 
From RowNumCTE
Where row_num >1


--Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP Column SaleDate

