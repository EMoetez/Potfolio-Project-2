SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

select *
from dbo.NashvilleHousing

--Standrdize SaleDate
select SaleDate, convert(date,SaleDate)
from dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = convert(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = convert(date,SaleDate)

select SaleDateConverted, convert(date,SaleDate)
from dbo.NashvilleHousing

-----------------------------------------------------------------------
--Populate property adress data

select PropertyAddress
from PortfolioProject..NashvilleHousing

select *
from PortfolioProject..NashvilleHousing

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    on a.[UniqueID ] <> b.[UniqueID ]
    and a.ParcelID = b.ParcelID
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress=  ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    on a.[UniqueID ] <> b.[UniqueID ]
    and a.ParcelID = b.ParcelID
where a.PropertyAddress is null

-----------------------------------------------------------------------------------
--Breaking down Adress into individual columns (adress, city, state)


select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Adress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyAdress nvarchar(255)

UPDATE NashvilleHousing
SET PropertyAdress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAdress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAdress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
----

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

----
ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select *
from PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------
--Replace Y,N to YES,No in SoldAsVacant


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant


select SoldAsVacant,
CASE when SoldAsVacant = 'N' then 'No'
     when SoldAsVacant = 'Y' then 'Yes'
	 ELSE SoldAsVacant
	 END
from PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant= CASE when SoldAsVacant = 'N' then 'No'
     when SoldAsVacant = 'Y' then 'Yes'
	 ELSE SoldAsVacant
	 END

----------------------------------------------------------------------------------------
--Remove Duplicates


--Using CTE
WITH RowNumCTE as(
select*, 
 ROW_NUMBER() OVER(
       PARTITION BY  ParcelID, 
	                 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY 
					 UniqueId) row_num
   
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num >1
--order by PropertyAddress


----------------------------------------------------------------------------------------------------
--Delete unused columns


select *
from PortfolioProject..NashvilleHousing

ALTER TABLE  PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
